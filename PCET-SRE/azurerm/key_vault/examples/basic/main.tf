resource "random_string" "name" {
  length  = 16
  number  = false
  special = false
}

resource "azurerm_resource_group" "key_vault" {
  name     = random_string.name.result
  location = "centralus"
}

module "key_vault" {
  source              = "../../"
  name                = random_string.name.result
  location            = azurerm_resource_group.key_vault.location
  resource_group_name = azurerm_resource_group.key_vault.name
  tenant_id           = var.tenant_id
  object_id           = var.object_id
}
