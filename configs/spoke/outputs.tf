output "vnet_id" {
  description = "Spoke virtual network ID."
  value       = module.vnet.id
}

output "subnet_ids" {
  description = "Spoke subnet IDs by name. configs/apim takes the APIManagement subnet from here."
  value       = module.vnet.subnet_ids
}

output "key_vault_ids" {
  description = "Spoke Key Vault IDs by purpose."
  value       = { for name, vault in module.key_vault : name => vault.id }
}

output "action_group_id" {
  description = "Spoke alert action group, where this spoke manages the subscription baseline."
  value       = one(module.alert_rules[*].action_group_id)
}

output "devops_identity" {
  description = "Spoke DevOps agent managed identity."
  value = {
    id           = module.devops_identity.id
    principal_id = module.devops_identity.principal_id
    client_id    = module.devops_identity.client_id
  }
}

output "terraform_state_storage_account" {
  description = "Storage account for this spoke's application Terraform state."
  value       = module.storage["tfstate"].name
}
