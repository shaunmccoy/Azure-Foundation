### VIRTUAL NETWORK ###

module "vnet" {
  source = "../../modules/vnet"

  name                       = "${local.prefix}-VNET"
  resource_group_name        = azurerm_resource_group.this["NET"].name
  location                   = var.location
  address_space              = var.vnet_cidr
  dns_servers                = var.dns_servers
  subnets                    = var.subnets
  log_analytics_workspace_id = local.log_analytics_workspace_id
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

module "additional_route_tables" {
  source   = "../../modules/user_defined_routes"
  for_each = var.additional_route_tables

  name                   = "${local.prefix}-UDR-${upper(each.key)}"
  resource_group_name    = azurerm_resource_group.this["NET"].name
  location               = var.location
  default_next_hop_type  = each.value.default_next_hop_type
  internet_route_cidrs   = each.value.internet_route_cidrs
  black_hole_route_cidrs = var.black_hole_route_cidrs
  tags                   = local.common_tags
}

resource "azurerm_subnet_route_table_association" "default" {
  for_each = var.subnets_with_default_udr == null ? setsubtract(keys(var.subnets), keys(local.route_table_subnets)) : var.subnets_with_default_udr

  subnet_id      = module.vnet.subnet_ids[each.value]
  route_table_id = module.user_defined_routes.id
}

resource "azurerm_subnet_route_table_association" "additional" {
  for_each = local.route_table_subnets

  subnet_id      = module.vnet.subnet_ids[each.key]
  route_table_id = module.additional_route_tables[each.value].id
}

### HUB PEERING ###

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  provider = azurerm.hub

  name                         = "VNET-PEER-${local.hub_names.vnet}-TO-${upper(module.vnet.name)}"
  resource_group_name          = local.hub_names.network_resource_group
  virtual_network_name         = local.hub_names.vnet
  remote_virtual_network_id    = module.vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "VNET-PEER-${upper(module.vnet.name)}-TO-${local.hub_names.vnet}"
  resource_group_name          = module.vnet.resource_group_name
  virtual_network_name         = module.vnet.name
  remote_virtual_network_id    = local.hub_vnet_id
  allow_virtual_network_access = true
  use_remote_gateways          = var.use_hub_gateway

  # use_remote_gateways is rejected until the hub side allows gateway transit.
  depends_on = [azurerm_virtual_network_peering.hub_to_spoke]
}

### FLOW LOGS ###

resource "azurerm_network_watcher" "this" {
  count = var.network_watcher == null ? 1 : 0

  name                = "NetworkWatcher-${upper(var.location)}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this["NET"].name
  tags                = local.common_tags
}

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
}
