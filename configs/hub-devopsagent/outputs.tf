output "agent_private_ip_addresses" {
  description = "Map of static agent VM name to private IP address."
  value       = module.agents.private_ip_addresses
}

output "agent_scaleset_id" {
  description = "Resource ID of the agent scale set, to select when creating the Azure DevOps scale-set pool."
  value       = one(module.autoscale_agents[*].id)
}

output "ssh_private_key_secret_name" {
  description = "Key Vault secret that holds the agents' SSH private key."
  value       = azurerm_key_vault_secret.agent_ssh_private_key.name
}

output "no_proxy" {
  description = "Destinations the agents reach without the proxy (from the DevOps route table)."
  value       = local.no_proxy
}
