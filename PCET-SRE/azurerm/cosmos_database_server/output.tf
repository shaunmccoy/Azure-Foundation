output id {
  value = azurerm_cosmosdb_account.db.id
}
output endpoint {
  value = azurerm_cosmosdb_account.db.endpoint
}
output read_endpoints {
  value = azurerm_cosmosdb_account.db.read_endpoints
}
output write_endpoints {
  value = azurerm_cosmosdb_account.db.write_endpoints
}
output primary_master_key {
  value = azurerm_cosmosdb_account.db.primary_master_key
}
output secondary_master_key {
  value = azurerm_cosmosdb_account.db.secondary_master_key
}
/*
#uncomment this if you are also creating private end point for cosmos database in the same module
output "private_end_point_id" {
    value = azurerm_private_endpoint.private_endpoint.id
}
output "private_endpoint_service_connection" {
  value = data.azurerm_private_endpoint_connection.endpoint_conn.private_service_connection
}*/






