resource "random_string" "name" {
  length  = 16
  number  = false
  special = false
}

resource "azurerm_resource_group" "azure_devops_agents" {
  name     = random_string.name.result
  location = "centralus"
}

resource "azurerm_virtual_network" "azure_devops_agents" {
  name                = random_string.name.result
  location            = azurerm_resource_group.azure_devops_agents.location
  resource_group_name = azurerm_resource_group.azure_devops_agents.name
  address_space       = ["192.168.13.0/24"]
}

resource "azurerm_subnet" "azure_devops_agents" {
  name                 = random_string.name.result
  resource_group_name  = azurerm_resource_group.azure_devops_agents.name
  virtual_network_name = azurerm_virtual_network.azure_devops_agents.name
  address_prefix       = "192.168.13.0/24"
}

module "azure_devops_agents" {
  source              = "../../"
  name                = random_string.name.result
  location            = azurerm_resource_group.azure_devops_agents.location
  resource_group_name = azurerm_resource_group.azure_devops_agents.name
  subnet_id           = azurerm_subnet.azure_devops_agents.id
  sku_name            = "Standard_DS2"
  capacity            = 2
  managed_disk_type   = "Premium_LRS"

  # Testing account
  admin_username = "testing"
  key_data       = "ssh-rsa REPLACE_WITH_PUBLIC_KEY"
}
