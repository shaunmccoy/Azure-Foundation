### VIRTUAL NETWORK ###

module "vnet" {
  source = "../../modules/vnet"

  name                       = local.hub_names.vnet
  resource_group_name        = azurerm_resource_group.this["NET"].name
  location                   = var.location
  address_space              = var.vnet_cidr
  dns_servers                = var.dns_servers
  subnets                    = var.subnets
  log_analytics_workspace_id = module.log_analytics.id
  tags                       = local.common_tags
}

### ROUTE TABLES ###

module "user_defined_routes" {
  source = "../../modules/user_defined_routes"

  name                   = "${local.prefix}-UDR-DEFAULT"
  resource_group_name    = azurerm_resource_group.this["NET"].name
  location               = var.location
  internet_route_cidrs   = var.internet_route_cidrs
  black_hole_route_cidrs = var.black_hole_route_cidrs
  tags                   = local.common_tags
}

module "devops_user_defined_routes" {
  source = "../../modules/user_defined_routes"

  name                   = local.hub_names.devops_route_table
  resource_group_name    = azurerm_resource_group.this["NET"].name
  location               = var.location
  default_next_hop_type  = "Internet"
  internet_route_cidrs   = concat(var.internet_route_cidrs, var.devops_cidrs)
  black_hole_route_cidrs = var.black_hole_route_cidrs
  tags                   = local.common_tags
}

# Application Gateway v2 requires 0.0.0.0/0 to go to the Internet.
module "appgateway_user_defined_routes" {
  source = "../../modules/user_defined_routes"

  name                   = "${local.prefix}-UDR-APPGATEWAY"
  resource_group_name    = azurerm_resource_group.this["NET"].name
  location               = var.location
  default_next_hop_type  = "Internet"
  internet_route_cidrs   = var.internet_route_cidrs
  black_hole_route_cidrs = var.black_hole_route_cidrs
  tags                   = local.common_tags
}

resource "azurerm_subnet_route_table_association" "default" {
  for_each = var.subnets_with_udrs

  subnet_id      = module.vnet.subnet_ids[each.value]
  route_table_id = module.user_defined_routes.id
}

resource "azurerm_subnet_route_table_association" "devops" {
  # Skipped where the agent subnet is listed in subnets_with_udrs and so already has the default table.
  count = contains(keys(var.subnets), "DevOpsAgents") && !contains(var.subnets_with_udrs, "DevOpsAgents") ? 1 : 0

  subnet_id      = module.vnet.subnet_ids["DevOpsAgents"]
  route_table_id = module.devops_user_defined_routes.id
}

resource "azurerm_subnet_route_table_association" "appgateway" {
  count = contains(keys(var.subnets), "AppGateway") ? 1 : 0

  subnet_id      = module.vnet.subnet_ids["AppGateway"]
  route_table_id = module.appgateway_user_defined_routes.id
}

### GATEWAYS ###

module "expressroute_network_gateway" {
  source = "../../modules/expressroute_network_gateway"

  name                        = "${local.prefix}-ERGW"
  public_ip_name              = "${local.prefix}-ERGW-PIP1"
  resource_group_name         = azurerm_resource_group.this["NET"].name
  location                    = var.location
  gateway_subnet_id           = module.vnet.subnet_ids["GatewaySubnet"]
  sku                         = var.expressroute_gateway_sku
  zones                       = var.zones
  primary_circuit_id          = var.express_route_circuit_id
  primary_authorization_key   = var.express_route_authorization_key
  secondary_circuit_id        = var.express_route_secondary_circuit_id
  secondary_authorization_key = var.express_route_secondary_authorization_key
  log_analytics_workspace_id  = module.log_analytics.id
  tags                        = local.common_tags
}

module "vpn_network_gateway" {
  source = "../../modules/vpn_network_gateway"
  count  = var.vpn == null ? 0 : 1

  name                       = "${local.prefix}-VPNGW"
  public_ip_name             = "${local.prefix}-VPNGW-PIP1"
  local_network_gateway_name = "${local.prefix}-LNGW-ONPREM"
  resource_group_name        = azurerm_resource_group.this["NET"].name
  location                   = var.location
  gateway_subnet_id          = module.vnet.subnet_ids["GatewaySubnet"]
  sku                        = var.vpn.sku
  zones                      = var.zones
  active_active              = var.vpn.active_active
  onprem_gateway_address     = var.vpn.onprem_gateway_address
  onprem_address_space       = var.vpn.onprem_address_space
  shared_key                 = var.vpn_shared_key
  log_analytics_workspace_id = module.log_analytics.id
  tags                       = local.common_tags

  # Two gateways cannot be provisioned in the same GatewaySubnet at the same time.
  depends_on = [module.expressroute_network_gateway]
}

### FLOW LOGS ###

resource "azurerm_network_watcher" "this" {
  count = var.network_watcher == null ? 1 : 0

  name                = "NetworkWatcher-${upper(var.location)}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this["NET"].name
  tags                = local.common_tags
}

# Virtual network flow logs replace NSG flow logs, which Azure is retiring.
resource "azurerm_network_watcher_flow_log" "vnet" {
  name                 = "${local.prefix}-VNET-FLOWLOG"
  network_watcher_name = var.network_watcher == null ? azurerm_network_watcher.this[0].name : var.network_watcher.name
  resource_group_name  = var.network_watcher == null ? azurerm_network_watcher.this[0].resource_group_name : var.network_watcher.resource_group_name
  location             = var.location
  target_resource_id   = module.vnet.id
  storage_account_id   = module.storage["flow"].id
  enabled              = true
  version              = 2
  tags                 = local.common_tags

  retention_policy {
    enabled = true
    days    = 30
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = module.log_analytics.workspace_id
    workspace_region      = var.location
    workspace_resource_id = module.log_analytics.id
    interval_in_minutes   = 10
  }
}
