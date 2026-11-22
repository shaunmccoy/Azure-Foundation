output "resource_group_name" {
  description = "Resource group reserved for the firewall deployment."
  value       = azurerm_resource_group.checkpoint.name
}

output "resource_group_id" {
  description = "Resource ID of the firewall resource group."
  value       = azurerm_resource_group.checkpoint.id
}
