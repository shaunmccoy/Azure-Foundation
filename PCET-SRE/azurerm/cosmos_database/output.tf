output "id" {
  value = azurerm_cosmosdb_account.db.id
}
output "endpoint" {
  value = azurerm_cosmosdb_account.db.endpoint
}
output "read_endpoints" {
  value = azurerm_cosmosdb_account.db.read_endpoints
}
output "write_endpoints" {
  value = azurerm_cosmosdb_account.db.write_endpoints
}
output "primary_master_key" {
  value = azurerm_cosmosdb_account.db.primary_master_key
}
output "secondary_master_key" {
  value = azurerm_cosmosdb_account.db.secondary_master_key
}
output "account_name" {
  value = azurerm_cosmosdb_account.db.name
}

output "cosmosdb_connectionstrings" {
   value = "AccountEndpoint=${azurerm_cosmosdb_account.db.endpoint};AccountKey=${azurerm_cosmosdb_account.db.primary_master_key};"
   sensitive   = true
}

output "cosmos_db_name" {
  value = azurerm_cosmosdb_sql_database.db.name
}



