
resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                =  var.log_analytics_workspace_name
  location            =  var.location
  resource_group_name =  var.resource_group_name
  sku                 =  var.sku #"PerGB2018"
  retention_in_days   =  var.retention_in_days #30
}

resource "azurerm_log_analytics_solution" "solution" {
  for_each              = var.solution_config 
  
  solution_name         = each.key
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics.name

  plan {
    publisher = each.value["publisher"]
    product   = each.value["product"]
  }
}