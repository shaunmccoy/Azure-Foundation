data "azurerm_client_config" "current"{
}

data "azurerm_resource_group" "storage" {
  name     = var.resource_group_name
}

data "azurerm_subnet" "storage" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

data "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
}

resource "azurerm_private_endpoint" "storage" {
  name                = data.azurerm_storage_account.storage.name
  location            = data.azurerm_storage_account.storage.location
  resource_group_name = data.azurerm_resource_group.storage.name
  subnet_id           = data.azurerm_subnet.storage.id

  private_service_connection {
    name                           = data.azurerm_storage_account.storage.name
    private_connection_resource_id = data.azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  tags = var.tags
}
