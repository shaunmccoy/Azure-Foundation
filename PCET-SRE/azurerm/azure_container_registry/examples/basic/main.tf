resource "random_string" "name" {
  length  = 16
  number  = false
  special = false
}

resource "azurerm_resource_group" "acr" {
  name     = random_string.name.result
  location = "centralus"
}

module "acr" {
  source              = "../../"
  name                = random_string.name.result
  location            = azurerm_resource_group.acr.location
  resource_group_name = azurerm_resource_group.acr.name
}