resource "azurerm_sql_database" "db" {
  name                             = var.db_name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  edition                          = var.db_edition
  collation                        = var.collation
  server_name                      = var.db_server_name
  create_mode                      = "Default"
  requested_service_objective_name = var.requested_service_objective_name
  zone_redundant                   = var.zone_redundant

  /*extended_auditing_policy {
    storage_endpoint                        = var.auditstore_primary_blob_endpoint
    storage_account_access_key              = var.auditstore_primary_access_key
    storage_account_access_key_is_secondary = false
    retention_in_days                       = 20
  }*/
  
  tags                             = var.tags
}

resource "azurerm_mssql_database_extended_auditing_policy" "audit_policy" {
  database_id                             = azurerm_sql_database.db.id
  storage_endpoint                        = var.auditstore_primary_blob_endpoint
  storage_account_access_key              = var.auditstore_primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 20
}
