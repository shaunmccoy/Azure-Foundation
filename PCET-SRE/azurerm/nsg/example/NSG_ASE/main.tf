data "azurerm_client_config" "current" {
}

data "azurerm_subnet" "ase_subnet" {
  name                 = var.ase_subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.vnet_resource_group_name
}


module "ase_nsg" {
  source = "../modules/nsg/"
  nsg_name                = var.nsg_name
  resource_group_name     = var.resource_group_name
  tags                    = var.tags
  nsg_rules               = var.nsg_rules
}

resource "azurerm_subnet_network_security_group_association" "ase_nsg_association" {
  subnet_id                 = data.azurerm_subnet.ase_subnet.id
  network_security_group_id =  module.ase_nsg.nsg.id
}


module "ase_udr" {
  source                  = "../modules/route-table/"
  route_table_name        = var.route_table_name
  resource_group_name     = var.resource_group_name
  tags                    = var.tags
}

resource "azurerm_subnet_route_table_association" "udr_association" {
  subnet_id      = data.azurerm_subnet.ase_subnet.id
  route_table_id = module.ase_udr.route_table.id
}
