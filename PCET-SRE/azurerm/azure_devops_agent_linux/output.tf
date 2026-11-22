output "private_ip_addresses" {
  value = azurerm_linux_virtual_machine.agents[*].private_ip_address
}
