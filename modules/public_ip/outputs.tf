output "id" {
  description = "Public IP resource ID."
  value       = azurerm_public_ip.this.id
}

output "ip_address" {
  description = "Allocated IP address."
  value       = azurerm_public_ip.this.ip_address
}

output "fqdn" {
  description = "FQDN, when domain_name_label is set."
  value       = azurerm_public_ip.this.fqdn
}
