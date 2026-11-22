resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days
  daily_quota_gb      = var.daily_quota_gb
  tags                = var.tags

  # Agents and apps authenticate with Entra ID; workspace shared keys stay off.
  local_authentication_enabled = false
}

# Replaces the legacy OMSGallery solutions (SecurityInsights, Security, AzureActivity,
# AgentHealthAssessment). Activity logs now arrive through subscription diagnostic
# settings and agent health through Azure Monitor Agent / VM insights.
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "this" {
  count = var.sentinel_enabled ? 1 : 0

  workspace_id = azurerm_log_analytics_workspace.this.id
}
