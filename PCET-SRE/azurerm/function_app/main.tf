resource "azurerm_function_app" "funcapp" {
  name                       = var.funcapp_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = var.ase_paln_id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storgae_account_access_key
  tags                       = var.tags
  app_settings              = var.app_settings
  version                   = "~3"
  identity {
    type = "SystemAssigned"
  }
}