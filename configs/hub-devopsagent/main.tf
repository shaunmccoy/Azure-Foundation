# One SSH key pair for the agent fleet. The private key never leaves state and
# the hub INFRA Key Vault; fetch it from the vault for break-glass access.
# The identity running Terraform needs Key Vault Secrets Officer on that vault
# and network line of sight to its private endpoint.
resource "tls_private_key" "agents" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "agent_ssh_private_key" {
  name         = "SSHKEY-${var.agent_admin_username}-${local.prefix}-DEVOPSAGENT"
  value        = tls_private_key.agents.private_key_openssh
  content_type = "OpenSSH private key"
  key_vault_id = data.azurerm_key_vault.infra.id
  tags         = local.common_tags
}

### STATIC AGENT VMS ###

resource "azurerm_resource_group" "devops_agent" {
  name     = "${local.prefix}-DEVOPSAGENT-RG"
  location = var.location
  tags     = local.common_tags
}

module "agents" {
  source = "../../modules/devops_agent_linux"

  num_agents                 = var.number_of_vms
  resource_group_name        = azurerm_resource_group.devops_agent.name
  location                   = azurerm_resource_group.devops_agent.location
  subnet_id                  = data.azurerm_subnet.devops_agents.id
  nsg_name                   = "${local.hub_prefix}-DEVOPSAGENT-NSG"
  vm_name_prefix             = local.vm_name_prefix
  linux_dialect              = var.agent_linux_dialect
  linux_image                = var.agent_linux_image
  admin_username             = var.agent_admin_username
  admin_ssh_public_key       = tls_private_key.agents.public_key_openssh
  managed_identity_ids       = [data.azurerm_user_assigned_identity.devops.id]
  devops_url                 = var.agent_devops_url
  devops_project_name        = var.agent_devops_project_name
  agent_pool_name            = var.agent_pool_name
  agent_pat_token            = var.agent_pat_token
  agent_version              = var.agent_version
  http_proxy                 = var.http_proxy
  https_proxy                = var.https_proxy
  no_proxy                   = local.no_proxy
  log_analytics_workspace_id = local.log_analytics_workspace_id
  tags                       = local.agent_tags
}
