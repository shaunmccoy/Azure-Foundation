data "azurerm_virtual_network" "vnet" {
  name = var.vnet_name
  resource_group_name = var.vnet_resource_group_name
}

data "azurerm_subnet" "subnet" {
  name =  var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name = var.vnet_resource_group_name
}

resource "azurerm_app_service_environment" "app_service_environment" {
  name                    = var.ase_name
  subnet_id               = data.azurerm_subnet.subnet.id
  pricing_tier            = var.pricing_tier
  front_end_scale_factor  = var.front_end_scale_factor
  tags                    = var.tags
  resource_group_name     = var.resource_group_name
  internal_load_balancing_mode = "Web, Publishing"

}

