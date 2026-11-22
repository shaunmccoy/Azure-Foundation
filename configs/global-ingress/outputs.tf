output "fqdn" {
  description = "Traffic Manager DNS name. Point the public API host name at it with a CNAME."
  value       = azurerm_traffic_manager_profile.this.fqdn
}

output "profile_id" {
  description = "Traffic Manager profile resource ID."
  value       = azurerm_traffic_manager_profile.this.id
}
