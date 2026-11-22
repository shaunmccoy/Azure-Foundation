### SCALE-SET AGENTS ###

# Instances boot from a pre-baked gallery image that already contains the agent
# under ~/agent, and register themselves at first boot (templates/init.sh.tftpl).
#
# Azure DevOps "scale set agent" pools and Managed DevOps Pools install and
# register the agent themselves, with no token in custom data. Moving to either
# makes templates/ and scaleset_pat_token unnecessary.

resource "azurerm_resource_group" "autoscale_agents" {
  count = var.scaleset_enabled ? 1 : 0

  name     = "${local.prefix}-AUTOSCALEAGENTS-RG"
  location = var.location
  tags     = local.common_tags
}

module "autoscale_agents" {
  count  = var.scaleset_enabled ? 1 : 0
  source = "../../modules/linux_scaleset"

  name                = local.vmss_name
  resource_group_name = azurerm_resource_group.autoscale_agents[0].name
  location            = azurerm_resource_group.autoscale_agents[0].location
  subnet_id           = data.azurerm_subnet.devops_agents.id
  source_image_id     = data.azurerm_shared_image.agent[0].id
  plan                = var.plan
  admin_username      = var.agent_admin_username
  ssh_public_key      = tls_private_key.agents.public_key_openssh
  identity_ids        = [data.azurerm_user_assigned_identity.devops.id]
  tags                = local.agent_tags

  custom_data = base64encode(templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
    init_script = base64encode(templatefile("${path.module}/templates/init.sh.tftpl", {
      agent_user          = var.agent_admin_username
      devops_url          = var.agent_devops_url
      agent_pat           = var.scaleset_pat_token
      agent_pool_name     = var.agent_scale_pool_name
      devops_project_name = var.agent_devops_project_name
      http_proxy          = var.http_proxy == null ? "" : var.http_proxy
      https_proxy         = var.https_proxy == null ? "" : var.https_proxy
    }))
  }))
}
