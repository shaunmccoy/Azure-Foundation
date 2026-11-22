
data "azurerm_virtual_network" "vnet" {
  name = var.vnet_name
  resource_group_name = var.vnet_resource_group_name
}
data "azurerm_subnet" "subnet" {
 
  #count = length(data.azurerm_virtual_network.vnet.subnets)
  
  name =  var.subnet_name#data.azurerm_virtual_network.vnet.subnets[count.index]
  virtual_network_name = var.vnet_name
  resource_group_name = var.vnet_resource_group_name
}

resource "azurerm_cognitive_account" "cognitive_service" {
  name                = var.cognitive_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = var.kind

  sku_name = var.sku_name

  tags = var.tags
}