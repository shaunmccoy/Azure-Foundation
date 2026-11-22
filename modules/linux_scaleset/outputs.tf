output "id" {
  description = "Scale set resource ID."
  value       = azurerm_linux_virtual_machine_scale_set.this.id
}

output "name" {
  description = "Scale set name."
  value       = azurerm_linux_virtual_machine_scale_set.this.name
}
