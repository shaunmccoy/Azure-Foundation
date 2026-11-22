

data "azurerm_virtual_network" "vnet" {
  name = var.vnet_name
  resource_group_name = var.vnet_resource_group_name
}
data "azurerm_subnet" "subnet" {
  name =  var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name = var.vnet_resource_group_name
}

resource "azurerm_private_endpoint" "private_endpoint" {

  # Basis this flag we decide whether to create an EndPoint or not
  count               = var.enable_private_endpoint ? 1 : 0

  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.subnet.id

  private_service_connection {
    name                           = var.private_endpoint_name
    private_connection_resource_id = var.private_connection_resource_id
    is_manual_connection           = false
    subresource_names              = var.subresource_name
  }
}