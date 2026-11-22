output "private_ip_addresses" {
  value = azurerm_windows_virtual_machine.windows_vm[*].private_ip_address
  depends_on = [azurerm_windows_virtual_machine.windows_vm, null_resource.winrmconfig]
}