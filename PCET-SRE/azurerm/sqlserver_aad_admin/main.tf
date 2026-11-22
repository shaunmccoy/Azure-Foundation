resource "azurerm_sql_active_directory_administrator" "main" {
  server_name         = var.server_name
  resource_group_name = var.resource_group_name
  login               = var.sql_aad_admin
  tenant_id           = var.tenant_id
  object_id           = var.object_id
}
