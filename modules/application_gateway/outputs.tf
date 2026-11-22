output "id" {
  description = "Application Gateway resource ID."
  value       = azurerm_application_gateway.this.id
}

output "name" {
  description = "Application Gateway name."
  value       = azurerm_application_gateway.this.name
}

output "firewall_policy_id" {
  description = "WAF policy resource ID, or null when WAF is disabled."
  value       = one(azurerm_web_application_firewall_policy.this[*].id)
}
