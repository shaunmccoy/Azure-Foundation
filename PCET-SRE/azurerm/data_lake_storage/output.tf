
output "data_lake_name" {
  description = "Name of the data lake"
  value       = var.data_lake_name
}
output "datalake_id" {
  description = "Resoruce id of the data lake"
  value       = azurerm_storage_data_lake_gen2_filesystem.adls2.id
}
output "storage_account_id" {
  description = "Primary DFS endpoint of the created storage account"
  value       = azurerm_storage_account.adls.id
}
output "storage_account_name" {
  description = "Storage account Name"
  value       = azurerm_storage_account.adls.name
}
output "storage_dfs_endpoint" {
  description = "Primary DFS endpoint of the created storage account"
  value       = azurerm_storage_account.adls.primary_dfs_endpoint
}

output "private_endpoint_fqdn" {
  value = azurerm_private_endpoint.adls2_endpoint.custom_dns_configs[0].fqdn
}

output "private_endpoint_ip_addresses" {
  value = azurerm_private_endpoint.adls2_endpoint.custom_dns_configs[0].ip_addresses
}
