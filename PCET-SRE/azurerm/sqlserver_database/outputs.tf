
output name {
  value = azurerm_sql_server.server.name
}
output id {
  value = azurerm_sql_server.server.id
}

output default_secondary_location {
  value       = azurerm_sql_database.db.default_secondary_location
}
