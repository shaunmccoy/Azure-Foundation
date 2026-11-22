resource "azurerm_resource_group" "test_rg" {
  name          = var.resource_group_name
  location      = var.location
  tags          = var.tags
}

module "recovery_vault" {
    # source                          = "git::https://dev.azure.com/example-org/example-project/_git/PCET-SRE//azurerm/loganalytics_workspace?ref=load_balancer"
    source = "../../../PCET-SRE/azurerm/recovery_vault"    

    vault_name            = var.vault_name

    resource_group_name           = azurerm_resource_group.test_rg.name
    location                      = azurerm_resource_group.test_rg.location
    log_analytics_workspace_id    = var.log_analytics_workspace_id
    tags                          = var.tags
    
}