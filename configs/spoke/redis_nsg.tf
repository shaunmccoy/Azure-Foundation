### REDIS SUBNET NSG ###
# Rules required by VNet-injected Azure Cache for Redis (Premium):
# https://learn.microsoft.com/azure/azure-cache-for-redis/cache-how-to-premium-vnet
# VNet injection is the legacy model; new caches should use Azure Managed Redis with a
# private endpoint in the PrivateLink subnet, which needs none of this.

locals {
  redis_enabled  = var.redis_subnet_name != null
  redis_prefixes = local.redis_enabled ? var.subnets[var.redis_subnet_name].address_prefixes : []

  # DNS: the Azure resolver and metadata endpoint, plus the virtual network's own DNS servers.
  redis_dns_targets = concat(["168.63.129.16", "169.254.169.254"], var.dns_servers)

  # src/dst: a service tag (or "*"), or null to mean the Redis subnet's own prefixes.
  redis_rules = {
    "Outbound-Redis-StoragePki" = {
      priority = 1100, direction = "Outbound", protocol = "Tcp", ports = ["80", "443"]
      src      = null, dst = "*", dst_cidrs = null, description = "Redis dependencies on Azure Storage and PKI"
    }
    "Outbound-Redis-KeyVault" = {
      priority = 1101, direction = "Outbound", protocol = "Tcp", ports = ["443"]
      src      = null, dst = "AzureKeyVault", dst_cidrs = null, description = "Redis dependency on Azure Key Vault"
    }
    "Outbound-Redis-AzureMonitor" = {
      priority = 1102, direction = "Outbound", protocol = "Tcp", ports = ["443"]
      src      = null, dst = "AzureMonitor", dst_cidrs = null, description = "Redis dependency on Azure Monitor"
    }
    "Outbound-Redis-DNS" = {
      priority = 1103, direction = "Outbound", protocol = "*", ports = ["53"]
      src      = null, dst = null, dst_cidrs = local.redis_dns_targets, description = "Redis dependency on DNS"
    }
    "Outbound-Redis-Internal" = {
      priority = 1104, direction = "Outbound", protocol = "Tcp", ports = ["8443", "10221-10231", "20226", "13000-13999", "15000-15999", "6379-6380"]
      src      = null, dst = null, dst_cidrs = null, description = "Internal communications for Redis"
    }
    "Inbound-Redis-Internal" = {
      priority = 1105, direction = "Inbound", protocol = "Tcp", ports = ["8443", "10221-10231", "20226"]
      src      = null, dst = null, dst_cidrs = null, description = "Internal communications for Redis"
    }
    "Inbound-Redis-Clients-LB" = {
      priority = 1106, direction = "Inbound", protocol = "Tcp", ports = ["6379-6380", "13000-13999", "15000-15999"]
      src      = "AzureLoadBalancer", dst = null, dst_cidrs = null, description = "Azure load balancer to Redis and Redis clusters"
    }
    "Inbound-Redis-LB" = {
      priority = 1107, direction = "Inbound", protocol = "*", ports = ["8500", "16001", "10221-10231"]
      src      = "AzureLoadBalancer", dst = null, dst_cidrs = null, description = "Azure load balancing"
    }
    "Inbound-Redis-Clients-VNet" = {
      priority = 1108, direction = "Inbound", protocol = "Tcp", ports = ["6379-6380", "13000-13999", "15000-15999"]
      src      = "VirtualNetwork", dst = null, dst_cidrs = null, description = "Client communication to Redis and Redis clusters"
    }
  }
}

resource "azurerm_network_security_group" "redis" {
  count = local.redis_enabled ? 1 : 0

  name                = "${local.prefix}-REDIS-NSG"
  resource_group_name = azurerm_resource_group.this["NET"].name
  location            = var.location
  tags                = local.common_tags
}

resource "azurerm_network_security_rule" "redis" {
  for_each = { for name, rule in local.redis_rules : name => rule if local.redis_enabled }

  name                        = each.key
  description                 = each.value.description
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = "Allow"
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_port_ranges     = each.value.ports
  resource_group_name         = azurerm_resource_group.this["NET"].name
  network_security_group_name = azurerm_network_security_group.redis[0].name

  source_address_prefix        = each.value.src
  source_address_prefixes      = each.value.src == null ? local.redis_prefixes : null
  destination_address_prefix   = each.value.dst
  destination_address_prefixes = each.value.dst == null ? coalesce(each.value.dst_cidrs, local.redis_prefixes) : null
}

resource "azurerm_subnet_network_security_group_association" "redis" {
  count = local.redis_enabled ? 1 : 0

  subnet_id                 = module.vnet.subnet_ids[var.redis_subnet_name]
  network_security_group_id = azurerm_network_security_group.redis[0].id

  depends_on = [azurerm_network_security_rule.redis]
}
