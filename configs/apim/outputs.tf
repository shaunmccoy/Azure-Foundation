output "api_management_id" {
  description = "API Management service resource ID."
  value       = module.api_management.id
}

output "api_management_name" {
  description = "API Management service name."
  value       = module.api_management.name
}

output "gateway_url" {
  description = "Default gateway URL."
  value       = module.api_management.gateway_url
}

output "gateway_regional_urls" {
  description = "Regional gateway URL per region."
  value       = module.api_management.gateway_regional_urls
}

output "private_ip_addresses" {
  description = "Private gateway IPs per region."
  value       = module.api_management.private_ip_addresses
}

output "regional_backend_fqdns" {
  description = "Per-region private DNS names to use as Application Gateway backends."
  value       = { for region, record in azurerm_private_dns_a_record.gateway : region => trimsuffix(record.fqdn, ".") }
}

output "identity" {
  description = "Identity the service uses for Key Vault and telemetry."
  value       = module.api_management.identity
}

output "developer_portal_url" {
  description = "Developer portal URL."
  value       = module.api_management.developer_portal_url
}
