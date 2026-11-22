### SCALE-SET BUILD AGENTS (optional) ###
# Instances boot from a pre-baked gallery image that already contains the agent and register
# themselves at first boot. Managed DevOps Pools need no token in custom data and are the
# preferred replacement.

resource "azurerm_resource_group" "autoscale_agents" {
  count = var.agent_scaleset == null ? 0 : 1

  name     = "${local.prefix}-AUTOSCALEAGENTS-RG"
  location = var.location
  tags     = local.common_tags
}

module "autoscale_agents" {
  source = "../../modules/linux_scaleset"
  count  = var.agent_scaleset == null ? 0 : 1

  name                = upper("${local.loc_code}${var.business_unit}${local.env_code}")
  resource_group_name = azurerm_resource_group.autoscale_agents[0].name
  location            = var.location
  zones               = var.zones
  subnet_id           = module.vnet.subnet_ids["DevOpsAgents"]
  source_image_id     = var.agent_scaleset.image_id
  plan                = var.agent_scaleset.plan
  admin_username      = var.agent_scaleset.admin_username
  ssh_public_key      = var.agent_scaleset.ssh_public_key
  identity_ids        = [coalesce(var.agent_scaleset.hub_identity_id, module.devops_identity.id)]
  tags                = merge(local.common_tags, { "${var.org_code}:operatingSystem" = "linux" })

  custom_data = base64encode(templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
    init_script = base64encode(templatefile("${path.module}/templates/init.sh.tftpl", {
      agent_user          = var.agent_scaleset.admin_username
      devops_url          = var.agent_scaleset.devops_url
      agent_pat           = var.scaleset_pat_token
      agent_pool_name     = var.agent_scaleset.pool_name
      devops_project_name = var.agent_scaleset.devops_project_name
      http_proxy          = ""
      https_proxy         = ""
    }))
  }))
}
