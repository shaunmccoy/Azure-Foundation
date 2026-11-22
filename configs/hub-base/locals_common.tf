# Identical in every config under configs/. Each config's locals.tf supplies
# local.prefix, local.subnet_type and local.resource_class.

locals {
  loc_code   = var.loc_code[var.location]
  env_code   = var.env_code[var.env]
  hub_prefix = "${local.loc_code}-HUB-${local.env_code}"

  common_tags = {
    "${var.org_code}:tla"           = lower(var.tla)
    "${var.org_code}:ecosystem"     = "azure"
    "${var.org_code}:dataCenter"    = lower(var.location)
    "${var.org_code}:environment"   = lower(var.env)
    "${var.org_code}:subnetType"    = local.subnet_type
    "${var.org_code}:resourceClass" = local.resource_class
    "${var.org_code}:costCenter"    = var.cost_center
    "${var.org_code}:businessUnit"  = lower(var.business_unit)
  }

  # Names the hub-base config gives its shared resources. Other configs look them up by name.
  hub_names = {
    network_resource_group  = "${local.hub_prefix}-NET-RG"
    vnet                    = "${local.hub_prefix}-VNET"
    keyvault_resource_group = "${local.hub_prefix}-KEYVAULT-RG"
    infra_keyvault          = "${local.hub_prefix}-INFRA-KV"
    identity_resource_group = "${local.hub_prefix}-IDENTITIES-RG"
    devops_identity         = "${local.hub_prefix}-IDENTITY-DEVOPSAGENT"
    devops_route_table      = "${local.hub_prefix}-UDR-DEVOPS"
    logs_resource_group     = "${local.hub_prefix}-LOGS-RG"
    log_analytics_workspace = "${local.hub_prefix}-AZLOGANALYTICS"
  }

  # Central Log Analytics workspace in the hub subscription, in the casing azurerm expects.
  log_analytics_workspace_id = provider::azurerm::normalise_resource_id(
    "/subscriptions/${var.hub_subscription_id}/resourceGroups/${local.hub_names.logs_resource_group}/providers/Microsoft.OperationalInsights/workspaces/${local.hub_names.log_analytics_workspace}"
  )
}
