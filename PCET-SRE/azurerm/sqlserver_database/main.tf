resource "azurerm_sql_server" "server" {
  name                         = var.db_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.server_version
  administrator_login          = var.sql_administrator_login
  administrator_login_password = var.sql_administrator_login_password
  connection_policy            = var.connection_policy
  
  tags                         = var.tags

  /*extended_auditing_policy {
    storage_endpoint                        = var.auditstore_primary_blob_endpoint
    storage_account_access_key              = var.auditstore_primary_access_key
    storage_account_access_key_is_secondary = false
    retention_in_days                       = 20
  }*/

}

resource "azurerm_sql_database" "db" {
  name                             = var.db_name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  edition                          = var.db_edition
  collation                        = var.collation
  server_name                      = azurerm_sql_server.server.name
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

resource "azurerm_sql_firewall_rule" "fw" {
  name                = "${var.db_name}-fwrules"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.server.name
  start_ip_address    = var.start_ip_address
  end_ip_address      = var.end_ip_address
}

resource "azurerm_mssql_server_extended_auditing_policy" "audit_policy" {
  server_id                               = azurerm_sql_server.server.id
  storage_endpoint                        = var.auditstore_primary_blob_endpoint
  storage_account_access_key              = var.auditstore_primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 20
}

resource "azurerm_mssql_database_extended_auditing_policy" "audit_policy" {
  database_id                             = azurerm_sql_database.db.id
  storage_endpoint                        = var.auditstore_primary_blob_endpoint
  storage_account_access_key              = var.auditstore_primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 20
}