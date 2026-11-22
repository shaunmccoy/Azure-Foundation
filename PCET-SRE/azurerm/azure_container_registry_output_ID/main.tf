resource "azurerm_container_registry" "acr" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  admin_enabled            = var.admin_enabled
  sku                      = var.sku
  georeplication_locations = var.georeplication_locations
  tags                     = var.tags
}
