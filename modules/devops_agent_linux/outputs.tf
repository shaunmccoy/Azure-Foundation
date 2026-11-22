output "vm_ids" {
  description = "Map of agent VM name to resource ID."
  value       = { for vm in azurerm_linux_virtual_machine.agents : vm.name => vm.id }
}

output "private_ip_addresses" {
  description = "Map of agent VM name to private IP address."
  value       = { for vm in azurerm_linux_virtual_machine.agents : vm.name => vm.private_ip_address }
}

output "network_security_group_id" {
  description = "Network security group attached to the agent NICs."
  value       = module.network_security_group.id
}
