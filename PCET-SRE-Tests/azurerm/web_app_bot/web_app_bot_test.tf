resource "azurerm_resource_group" "test_rg" {
  name          = var.resource_group_name
  location      = var.location
  tags          = var.tags
}

module "web_app_bot" {
    # source                          = "git::https://dev.azure.com/example-org/example-project/_git/PCET-SRE//azurerm/loganalytics_workspace?ref=load_balancer"
    source = "../../../PCET-SRE/azurerm/web_app_bot"    

    bot_name            = var.bot_name
    bot_sku             = var.bot_sku
    bot_application_id  = var.bot_application_id
    global_app_ind      = var.global_app_ind
    bot_endpoint        = var.bot_endpoint

    resource_group_name           = azurerm_resource_group.test_rg.name
    location                      = azurerm_resource_group.test_rg.location
    log_analytics_workspace_id    = var.log_analytics_workspace_id
    tags                          = var.tags
    
}