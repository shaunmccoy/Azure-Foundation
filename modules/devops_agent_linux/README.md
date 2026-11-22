# Azure DevOps Linux agents

Deploys a set of self-hosted Azure Pipelines agents on Linux VMs, spread across availability
zones, behind a dedicated network security group.

Each VM runs a first-boot script (`debian_init.sh.tftpl` or `rhel_init.sh.tftpl`, chosen by
`linux_dialect`) that installs the Azure CLI, PowerShell, Docker and AzCopy, then downloads,
registers and starts `agents_per_vm` agents. Script output is in
`/var/log/cloud-init-output.log` on the VM. Keep the two scripts installing the same software.

Notes:

* Agents register with a personal access token passed through VM custom data. The token is only
  needed at first boot; give it the *Agent Pools (Read & manage)* scope and a short lifetime.
  Managed DevOps Pools, or scale-set agents (`modules/linux_scaleset`), avoid the token entirely.
* Login is by SSH key only. Pass the public key in `admin_ssh_public_key`.
* Changing `custom_data` inputs (token, script, proxy) does not rebuild existing VMs. Remove the
  old agent from the pool in Azure DevOps and `terraform apply -replace=...` the VM to rebuild it.

## Example

```hcl
module "agents" {
  source = "../../modules/devops_agent_linux"

  num_agents                 = 2
  resource_group_name        = azurerm_resource_group.devops_agent.name
  location                   = azurerm_resource_group.devops_agent.location
  subnet_id                  = data.azurerm_subnet.devops_agents.id
  nsg_name                   = "${local.hub_prefix}-DEVOPSAGENT-NSG"
  vm_name_prefix             = local.vm_name_prefix
  admin_ssh_public_key       = tls_private_key.agents.public_key_openssh
  managed_identity_ids       = [data.azurerm_user_assigned_identity.devops.id]
  devops_url                 = var.agent_devops_url
  devops_project_name        = var.agent_devops_project_name
  agent_pool_name            = var.agent_pool_name
  agent_pat_token            = var.agent_pat_token
  log_analytics_workspace_id = local.log_analytics_workspace_id
  tags                       = local.common_tags
}
```
