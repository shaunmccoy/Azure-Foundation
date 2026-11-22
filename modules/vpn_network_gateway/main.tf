locals {
  public_ip_names = var.active_active ? [var.public_ip_name, "${var.public_ip_name}-2"] : [var.public_ip_name]
}

module "public_ip" {
  source   = "../public_ip"
  for_each = toset(local.public_ip_names)

  name                       = each.value
  resource_group_name        = var.resource_group_name
  location                   = var.location
  zones                      = var.zones
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = var.tags
}

resource "azurerm_virtual_network_gateway" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  generation          = "Generation2"
  sku                 = var.sku
  active_active       = var.active_active
  bgp_enabled         = var.bgp_asn != null
  tags                = var.tags

  dynamic "ip_configuration" {
    for_each = local.public_ip_names

    content {
      name                          = "VNetGatewayConfig${ip_configuration.key + 1}"
      public_ip_address_id          = module.public_ip[ip_configuration.value].id
      private_ip_address_allocation = "Dynamic"
      subnet_id                     = var.gateway_subnet_id
    }
  }

  dynamic "bgp_settings" {
    for_each = var.bgp_asn == null ? [] : [var.bgp_asn]

    content {
      asn = bgp_settings.value
    }
  }

  timeouts {
    create = "90m"
    update = "90m"
    delete = "90m"
  }
}

resource "azurerm_local_network_gateway" "onprem" {
  name                = var.local_network_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  gateway_address     = var.onprem_gateway_address
  address_space       = var.onprem_address_space
  tags                = var.tags

  dynamic "bgp_settings" {
    for_each = var.onprem_bgp == null ? [] : [var.onprem_bgp]

    content {
      asn                 = bgp_settings.value.asn
      bgp_peering_address = bgp_settings.value.peering_address
    }
  }
}

resource "azurerm_virtual_network_gateway_connection" "onprem" {
  name                       = "${var.name}-CONN-ONPREM"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  type                       = "IPsec"
  connection_protocol        = "IKEv2"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem.id
  shared_key                 = var.shared_key
  bgp_enabled                = var.bgp_asn != null
  tags                       = var.tags

  # Explicit policy instead of the permissive platform default proposals.
  ipsec_policy {
    ike_encryption   = "GCMAES256"
    ike_integrity    = "SHA384"
    dh_group         = "ECP384"
    ipsec_encryption = "GCMAES256"
    ipsec_integrity  = "GCMAES256"
    pfs_group        = "ECP384"
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "LOGANALYTICS-DIAGNOSTICS"
  target_resource_id         = azurerm_virtual_network_gateway.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
