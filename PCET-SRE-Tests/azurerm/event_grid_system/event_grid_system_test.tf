
resource "azurerm_resource_group" "test_rg" {
  name          = var.resource_group_name
  location      = var.location
  tags          = var.tags
}

resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.test_rg.name
  location                 = azurerm_resource_group.test_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = var.tags
}

module "event_grid_system" {
    # source                          = "git::https://dev.azure.com/example-org/example-project/_git/PCET-SRE//azurerm/event_grid_system?ref=data_factory"
    source = "../../../PCET-SRE/azurerm/event_grid_system"    

    deployment_name                 = var.deployment_name
    subscription_id                 = var.subscription_id

    event_grid_name                 = var.event_grid_name
    event_source_resource_id        = azurerm_storage_account.example.id
    event_source_topic_type         = "Microsoft.Storage.StorageAccounts"

    log_analytics_workspace_id      = var.log_analytics_workspace_id
    resource_group_name             = azurerm_resource_group.test_rg.name
    location                        = var.location
    tags                            = var.tags

}