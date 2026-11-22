output "id" {
  description = "Gateway resource ID."
  value       = azurerm_virtual_network_gateway.this.id
}

output "name" {
  description = "Gateway name."
  value       = azurerm_virtual_network_gateway.this.name
}

output "connection_ids" {
  description = "IDs of the circuit connections that were created."
  value = merge(
    { for c in azurerm_virtual_network_gateway_connection.primary : "primary" => c.id },
    { for c in azurerm_virtual_network_gateway_connection.secondary : "secondary" => c.id },
  )
}
