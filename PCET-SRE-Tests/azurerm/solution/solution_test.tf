resource "azurerm_resource_group" "test_rg" {
  name          = var.resource_group_name
  location      = var.location
  tags          = var.tags
}

module "loganalytics_workspace" {
    # source                          = "git::https://dev.azure.com/example-org/example-project/_git/PCET-SRE//azurerm/loganalytics_workspace?ref=load_balancer"
    source = "../../../PCET-SRE/azurerm/loganalytics_workspace"    

    log_analytics_workspace_name  = var.log_analytics_workspace_name
    solution_config               = var.solution_config
    sku                           = "PerGB2018"
    retention_in_days             = 30

    resource_group_name           = azurerm_resource_group.test_rg.name
    location                      = azurerm_resource_group.test_rg.location
    tags                          = var.tags
    
}