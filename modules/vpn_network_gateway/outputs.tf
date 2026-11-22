output "id" {
  description = "Gateway resource ID."
  value       = azurerm_virtual_network_gateway.this.id
}

output "name" {
  description = "Gateway name."
  value       = azurerm_virtual_network_gateway.this.name
}

output "public_ip_addresses" {
  description = "Public IPs the on-premises device must peer with."
  value       = [for name in local.public_ip_names : module.public_ip[name].ip_address]
}

output "connection_id" {
  description = "ID of the site-to-site connection."
  value       = azurerm_virtual_network_gateway_connection.onprem.id
}
