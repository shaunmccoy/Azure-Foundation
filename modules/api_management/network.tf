# Network security group rules API Management (stv2, VNet-injected) needs to stay healthy.
# https://learn.microsoft.com/azure/api-management/virtual-network-reference

locals {
  nsg_regions = var.manage_subnet_nsg ? local.regions : {}

  nsg_rules = merge(
    {
      "Allow-Management-Inbound" = {
        priority    = 100, direction = "Inbound", protocol = "Tcp", ports = ["3443"]
        source      = "ApiManagement", destination = "VirtualNetwork"
        description = "Azure control plane to the management endpoint"
      }
      "Allow-LoadBalancer-Inbound" = {
        priority    = 110, direction = "Inbound", protocol = "Tcp", ports = ["6390"]
        source      = "AzureLoadBalancer", destination = "VirtualNetwork"
        description = "Azure infrastructure load balancer health probe"
      }
      "Allow-Client-Inbound" = {
        priority    = 120, direction = "Inbound", protocol = "Tcp", ports = ["443"]
        source      = var.client_address_prefix, destination = "VirtualNetwork"
        description = "API clients to the gateway"
      }
      "Allow-Sync-Tcp-Inbound" = {
        priority    = 130, direction = "Inbound", protocol = "Tcp", ports = ["6381-6383"]
        source      = "VirtualNetwork", destination = "VirtualNetwork"
        description = "Internal cache and rate-limit sync between units"
      }
      "Allow-Sync-Udp-Inbound" = {
        priority    = 140, direction = "Inbound", protocol = "Udp", ports = ["4290"]
        source      = "VirtualNetwork", destination = "VirtualNetwork"
        description = "Rate-limit counter sync between units"
      }
      "Deny-All-Inbound" = {
        priority    = 4096, direction = "Inbound", access = "Deny", protocol = "*", ports = ["*"]
        source      = "*", destination = "*"
        description = "Deny everything else inbound"
      }
      "Allow-Storage-Outbound" = {
        priority    = 100, direction = "Outbound", protocol = "Tcp", ports = ["443"]
        source      = "VirtualNetwork", destination = "Storage"
        description = "Dependency on Azure Storage"
      }
      "Allow-Sql-Outbound" = {
        priority    = 110, direction = "Outbound", protocol = "Tcp", ports = ["1433"]
        source      = "VirtualNetwork", destination = "Sql"
        description = "Dependency on Azure SQL"
      }
      "Allow-KeyVault-Outbound" = {
        priority    = 120, direction = "Outbound", protocol = "Tcp", ports = ["443"]
        source      = "VirtualNetwork", destination = "AzureKeyVault"
        description = "Certificates and named values from Key Vault"
      }
      "Allow-Monitor-Outbound" = {
        priority    = 130, direction = "Outbound", protocol = "Tcp", ports = ["443", "1886"]
        source      = "VirtualNetwork", destination = "AzureMonitor"
        description = "Diagnostics, metrics and Application Insights"
      }
      "Allow-EntraId-Outbound" = {
        priority    = 140, direction = "Outbound", protocol = "Tcp", ports = ["443"]
        source      = "VirtualNetwork", destination = "AzureActiveDirectory"
        description = "Managed identity tokens and Entra ID sign-in"
      }
      "Allow-Sync-Tcp-Outbound" = {
        priority    = 150, direction = "Outbound", protocol = "Tcp", ports = ["6380-6383"]
        source      = "VirtualNetwork", destination = "VirtualNetwork"
        description = "Internal and external cache, rate-limit sync"
      }
      "Allow-Sync-Udp-Outbound" = {
        priority    = 160, direction = "Outbound", protocol = "Udp", ports = ["4290"]
        source      = "VirtualNetwork", destination = "VirtualNetwork"
        description = "Rate-limit counter sync between units"
      }
    },
    var.virtual_network_type == "External" ? {
      "Allow-Internet-Inbound" = {
        priority    = 150, direction = "Inbound", protocol = "Tcp", ports = ["443"]
        source      = "Internet", destination = "VirtualNetwork"
        description = "Public clients to the gateway"
      }
      "Allow-TrafficManager-Inbound" = {
        priority    = 160, direction = "Inbound", protocol = "Tcp", ports = ["443"]
        source      = "AzureTrafficManager", destination = "VirtualNetwork"
        description = "Built-in multi-region routing health probes"
      }
    } : {},
  )

  nsg_region_rules = merge([
    for region in keys(local.nsg_regions) : {
      for rule_name, rule in local.nsg_rules : "${region}/${rule_name}" => merge(rule, { region = region, name = rule_name })
    }
  ]...)
}

resource "azurerm_network_security_group" "this" {
  for_each = local.nsg_regions

  name                = "${var.name}-NSG-${upper(each.key)}"
  resource_group_name = var.resource_group_name
  location            = each.key
  tags                = var.tags
}

resource "azurerm_network_security_rule" "this" {
  for_each = local.nsg_region_rules

  name                        = each.value.name
  description                 = each.value.description
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = lookup(each.value, "access", "Allow")
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_port_ranges     = each.value.ports
  source_address_prefix       = each.value.source
  destination_address_prefix  = each.value.destination
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this[each.value.region].name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = local.nsg_regions

  subnet_id                 = each.value.subnet_id
  network_security_group_id = azurerm_network_security_group.this[each.key].id

  # Attach only once the rules exist, so the service never starts behind a half-built NSG.
  depends_on = [azurerm_network_security_rule.this]
}

resource "azurerm_monitor_diagnostic_setting" "nsg" {
  for_each = local.nsg_regions

  name                       = "LOGANALYTICS-DIAGNOSTICS"
  target_resource_id         = azurerm_network_security_group.this[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
}
