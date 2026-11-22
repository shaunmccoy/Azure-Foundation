module "public_ip" {
  source = "../public_ip"

  name                       = var.public_ip_name
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
  type                = "ExpressRoute"
  sku                 = var.sku
  tags                = var.tags

  ip_configuration {
    name                          = "VNetGatewayConfig"
    public_ip_address_id          = module.public_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  timeouts {
    create = "90m"
    update = "90m"
    delete = "90m"
  }
}

resource "azurerm_virtual_network_gateway_connection" "primary" {
  count = var.primary_circuit_id == null ? 0 : 1

  name                       = "${var.name}-CONN"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  type                       = "ExpressRoute"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
  express_route_circuit_id   = var.primary_circuit_id
  authorization_key          = var.primary_authorization_key
  routing_weight             = 10
  tags                       = var.tags
}

resource "azurerm_virtual_network_gateway_connection" "secondary" {
  count = var.secondary_circuit_id == null ? 0 : 1

  name                       = "${var.name}-CONN-SEC"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  type                       = "ExpressRoute"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
  express_route_circuit_id   = var.secondary_circuit_id
  authorization_key          = var.secondary_authorization_key
  routing_weight             = var.secondary_routing_weight
  tags                       = var.tags
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
