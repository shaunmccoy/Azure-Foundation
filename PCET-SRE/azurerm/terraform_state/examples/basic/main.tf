resource "random_string" "name" {
  length  = 16
  number  = false
  special = false
}

resource "azurerm_resource_group" "terraform_state" {
  name     = random_string.name.result
  location = "centralus"
}

module "terraform_state" {
  source              = "../../"
  name                = random_string.name.result
  location            = azurerm_resource_group.terraform_state.location
  resource_group_name = azurerm_resource_group.terraform_state.name
}
