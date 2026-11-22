output "container_name" {
  value = azurerm_cosmosdb_sql_container.container.*.name
}

output "container_id" {
  value = azurerm_cosmosdb_sql_container.container.*.id
}