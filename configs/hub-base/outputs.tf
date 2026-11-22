output "vnet_id" {
  description = "Hub virtual network ID."
  value       = module.vnet.id
}

output "subnet_ids" {
  description = "Hub subnet IDs by name."
  value       = module.vnet.subnet_ids
}

output "log_analytics_workspace_id" {
  description = "Central Log Analytics workspace resource ID."
  value       = module.log_analytics.id
}

output "action_group_id" {
  description = "Platform alert action group."
  value       = module.alert_rules.action_group_id
}

output "key_vault_ids" {
  description = "Hub Key Vault IDs by purpose."
  value       = { for name, vault in module.key_vault : name => vault.id }
}

output "devops_identity" {
  description = "DevOps agent managed identity."
  value = {
    id           = module.devops_identity.id
    principal_id = module.devops_identity.principal_id
    client_id    = module.devops_identity.client_id
  }
}

output "expressroute_gateway_id" {
  description = "ExpressRoute gateway resource ID."
  value       = module.expressroute_network_gateway.id
}

output "vpn_gateway_public_ip_addresses" {
  description = "VPN gateway public IPs for the on-premises device, when a VPN gateway is deployed."
  value       = one(module.vpn_network_gateway[*].public_ip_addresses)
}

output "private_dns_zone_ids" {
  description = "Central private DNS zone IDs, on the hub that hosts them."
  value       = one(module.private_dns[*].zone_ids)
}

output "acr_login_server" {
  description = "Container registry login server."
  value       = azurerm_container_registry.this.login_server
}

output "terraform_state_storage_account" {
  description = "Storage account for Terraform state of this hub and its spokes."
  value       = module.storage["tfstate"].name
}
