locals {
  loc_code = var.loc_code[var.location]
  env_code      = var.env_code[var.env]

  common_tags = {
    "sm:tla"                      = lower(var.tla)
    "sm:ecosystem"                = "azure"
    "sm:datacenter"               = lower(var.location)
    "sm:environment"              = lower(var.env)
    "sm:subnettype"               = "private"
    "sm:resourceclass"            = "app"

    "sm:costcenter"               = var.cost_center
    "sm:businessunit"             = lower(var.business_unit)
  }
  
  prefix = "${local.loc_code}-${var.business_unit}-${local.env_code}"
  hub_prefix = "${local.loc_code}-HUB-${local.env_code}"
  
  log_analytics_workspace_id = lower("/subscriptions/${var.hub_subscription_id}/resourcegroups/${local.hub_prefix}-logs-rg/providers/microsoft.operationalinsights/workspaces/${local.hub_prefix}-azloganalytics")
}

provider "azurerm" {
