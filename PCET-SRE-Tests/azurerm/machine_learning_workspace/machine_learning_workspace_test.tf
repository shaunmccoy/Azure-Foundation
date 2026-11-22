
resource "azurerm_resource_group" "test_rg" {
  name          = var.resource_group_name
  location      = var.location
  tags          = var.tags
}

resource "azurerm_virtual_network" "machine_learning" {
  name                = "machine_learning_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test_rg.location
  resource_group_name = azurerm_resource_group.test_rg.name
}

resource "azurerm_subnet" "machine_learning" {
  name                 = "machine_learning_subnet"
  resource_group_name  = azurerm_resource_group.test_rg.name
  virtual_network_name = azurerm_virtual_network.machine_learning.name
  address_prefixes     = ["10.0.1.0/24"]

  enforce_private_link_endpoint_network_policies = true

  service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ContainerRegistry"]

}

module "machine_learning_workspace" {
    # source                          = "git::https://dev.azure.com/example-org/example-project/_git/PCET-SRE//azurerm/machine_learning_workspace?ref=machine_learning"
    source = "../../../PCET-SRE/azurerm/machine_learning_workspace"    

    deployment_name                 = var.deployment_name
    machine_learning_workspace_name = var.machine_learning_workspace_name
    workspace_private_endpoint_name = var.private_endpoint_name
    secure_dependent_resources      = true

    key_vault_name                  = "examplelabmlvault"
    key_vault_disk_purge_protection = false
    storage_account_name            = "examplelabmlstorage"
    storage_account_account_replication = "LRS"
    
    container_registry_name         = "examplelabmlcontainerreg"
    app_insights_name               = "machine-learning-app-insights"

    vnet_name                       = azurerm_virtual_network.machine_learning.name
    vnet_rg_name                    = azurerm_resource_group.test_rg.name
    subnet_name                     = azurerm_subnet.machine_learning.name

    log_analytics_workspace_id      = var.log_analytics_workspace_id
    resource_group_name             = azurerm_resource_group.test_rg.name
    location                        = var.location
    tags                            = var.tags

}