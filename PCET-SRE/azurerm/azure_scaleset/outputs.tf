output "scale_id" {
  value       = azurerm_linux_virtual_machine_scale_set.vmss.id
  description = "ID of the scaleset"
}
