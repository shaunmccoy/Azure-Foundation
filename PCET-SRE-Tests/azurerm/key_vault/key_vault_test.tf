resource "azurerm_resource_group" "test_rg" {
  name          = var.resource_group_name
  location      = var.location
  tags          = var.tags
}

data "azurerm_client_config" "current" {}

output object_id {
  value = data.azurerm_client_config.current.object_id
}

output keyvault {
  value = module.key_vault.key_vault
}

resource "azurerm_virtual_network" "keyvault_vnet" {
  name                = "keyvault_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test_rg.location
  resource_group_name = azurerm_resource_group.test_rg.name
}

resource "azurerm_subnet" "keyvault_subnet" {
  name                 = "keyvault_subnet"
  resource_group_name  = azurerm_resource_group.test_rg.name
  virtual_network_name = azurerm_virtual_network.keyvault_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

module "key_vault" {
    # source                          = "git::https://dev.azure.com/example-org/example-project/_git/PCET-SRE//azurerm/key_vault?ref=1.0.0"
    source = "../../../PCET-SRE/azurerm/key_vault"    

    name                          = var.vault_name

    resource_group_name           = azurerm_resource_group.test_rg.name
    location                      = azurerm_resource_group.test_rg.location
    secure_resources              = true
    object_id_list                = [data.azurerm_client_config.current.object_id]
    subnet_id                     = azurerm_subnet.keyvault_subnet.id

    key_permissions               = ["get"]
    secret_permissions            = ["get"]

    log_analytics_workspace_id    = var.log_analytics_workspace_id
    tags                          = var.tags
    
}