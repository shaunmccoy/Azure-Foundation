resource "azurerm_app_service" "appsvc" {
  name                = var.appsvc_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = var.ase_paln_id
  tags                = var.tags
  app_settings              = var.app_settings

   identity {
    type = "SystemAssigned"
  }
}