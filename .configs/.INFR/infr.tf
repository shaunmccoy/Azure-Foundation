locals {
  loc_code = var.loc_code[var.location]
  env_code = var.env_code[var.env]

  common_tags = {
    "sm:tla"           = lower(var.tla)
    "sm:ecosystem"     = "azure"
    "sm:datacenter"    = lower(var.location)
    "sm:environment"   = lower(var.env)
    "sm:subnettype"    = "private"
    "sm:resourceclass" = "app"

    "sm:costcenter"   = var.cost_center
    "sm:businessunit" = lower(var.business_unit)
  }

  prefix     = "${local.loc_code}-${var.business_unit}-${local.env_code}"
  hub_prefix = "${local.loc_code}-HUB-${local.env_code}"

  # Central Log Analytics workspace that lives in the hub subscription.
  # The ID is no longer lower()-cased: azurerm parses resource IDs
  # case-sensitively ("resourceGroups", "Microsoft.OperationalInsights"),
  # and a lower-cased ID fails validation or causes perpetual diffs on
  # resources such as azurerm_monitor_diagnostic_setting.
  log_analytics_workspace_id = provider::azurerm::normalise_resource_id(
    "/subscriptions/${var.hub_subscription_id}/resourceGroups/${local.hub_prefix}-logs-rg/providers/Microsoft.OperationalInsights/workspaces/${local.hub_prefix}-azloganalytics"
  )
}
