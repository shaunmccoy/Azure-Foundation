output "id" {
  description = "API Management service resource ID."
  value       = azurerm_api_management.this.id
}

output "name" {
  description = "API Management service name."
  value       = azurerm_api_management.this.name
}

output "gateway_url" {
  description = "Default gateway URL."
  value       = azurerm_api_management.this.gateway_url
}

output "gateway_regional_urls" {
  description = "Regional gateway URL per region."
  value = merge(
    { (var.location) = azurerm_api_management.this.gateway_regional_url },
    {
      for location in keys(var.additional_locations) :
      location => one([for l in azurerm_api_management.this.additional_location : l.gateway_regional_url if l.location == location])
    },
  )
}

output "private_ip_addresses" {
  description = "Private gateway IPs per region (Internal mode). Point regional DNS records and Application Gateway pools here."
  value = merge(
    { (var.location) = azurerm_api_management.this.private_ip_addresses },
    {
      for location in keys(var.additional_locations) :
      location => one([for l in azurerm_api_management.this.additional_location : l.private_ip_addresses if l.location == location])
    },
  )
}

output "public_ip_addresses" {
  description = "Public IPs per region, whether Azure-managed or your own (management traffic only in Internal mode)."
  value = merge(
    { (var.location) = azurerm_api_management.this.public_ip_addresses },
    {
      for location in keys(var.additional_locations) :
      location => one([for l in azurerm_api_management.this.additional_location : l.public_ip_addresses if l.location == location])
    },
  )
}

output "management_api_url" {
  description = "Management API URL."
  value       = azurerm_api_management.this.management_api_url
}

output "developer_portal_url" {
  description = "Developer portal URL."
  value       = azurerm_api_management.this.developer_portal_url
}

output "identity" {
  description = "User-assigned identity the service uses for Key Vault and telemetry."
  value = {
    id           = azurerm_user_assigned_identity.this.id
    principal_id = azurerm_user_assigned_identity.this.principal_id
    client_id    = azurerm_user_assigned_identity.this.client_id
  }
}

output "application_insights_id" {
  description = "Application Insights component ID, or null when disabled."
  value       = one(azurerm_application_insights.this[*].id)
}
