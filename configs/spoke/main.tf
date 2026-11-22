### RESOURCE GROUPS ###

resource "azurerm_resource_group" "this" {
  for_each = toset(["ALERTS", "IDENTITIES", "KEYVAULT", "NET", "PRIVATELINK", "STORAGE"])

  name     = "${local.prefix}-${each.key}-RG"
  location = var.location
  tags     = local.common_tags
}

### ALERTS AND SECURITY ###

module "alert_rules" {
  source = "../../modules/alert_rules"
  count  = var.subscription_baseline_enabled ? 1 : 0

  resource_group_name = azurerm_resource_group.this["ALERTS"].name
  subscription_id     = var.subscription_id
  action_group_name   = "${local.loc_code}-${var.env} - L1 EMAIL ALERTS"
  email_address       = var.alert_email_group
  policy_alert_prefix = upper(var.org_code)
  tags                = local.common_tags
}

resource "azurerm_security_center_subscription_pricing" "this" {
  for_each = var.subscription_baseline_enabled ? var.defender_plans : []

  tier          = "Standard"
  resource_type = each.value
}

resource "azurerm_security_center_workspace" "this" {
  count = var.subscription_baseline_enabled ? 1 : 0

  scope        = "/subscriptions/${var.subscription_id}"
  workspace_id = local.log_analytics_workspace_id

  depends_on = [azurerm_security_center_subscription_pricing.this]
}

# Subscription activity log to the hub's Log Analytics workspace.
resource "azurerm_monitor_diagnostic_setting" "activity_log" {
  count = var.subscription_baseline_enabled ? 1 : 0

  name                       = "LOGANALYTICS-ACTIVITY"
  target_resource_id         = "/subscriptions/${var.subscription_id}"
  log_analytics_workspace_id = local.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = toset(["Administrative", "Security", "ServiceHealth", "Alert", "Recommendation", "Policy", "Autoscale", "ResourceHealth"])

    content {
      category = enabled_log.value
    }
  }
}

### MANAGED IDENTITY ###

module "devops_identity" {
  source = "../../modules/managed_identity"

  name                = "${local.prefix}-IDENTITY-DEVOPSAGENT"
  resource_group_name = azurerm_resource_group.this["IDENTITIES"].name
  location            = var.location
  tags                = local.common_tags
}

### STORAGE ###

module "storage" {
  source = "../../modules/storage_account"
  for_each = {
    vmdiag  = { allow_azure_services = true, versioning = false }
    flow    = { allow_azure_services = true, versioning = false }
    tfstate = { allow_azure_services = false, versioning = true }
  }

  name                     = "${local.storage_prefix}${each.key}01"
  resource_group_name      = azurerm_resource_group.this["STORAGE"].name
  location                 = var.location
  account_replication_type = length(var.zones) > 0 ? "ZRS" : "LRS"
  allow_azure_services     = each.value.allow_azure_services
  blob_versioning_enabled  = each.value.versioning

  private_endpoints = {
    blob = {
      subnet_id            = module.vnet.subnet_ids["PrivateLink"]
      private_dns_zone_ids = [local.central_dns_zone_ids["privatelink.blob.core.windows.net"]]
    }
  }

  private_endpoint_resource_group_name = azurerm_resource_group.this["PRIVATELINK"].name
  log_analytics_workspace_id           = local.log_analytics_workspace_id
  tags                                 = local.common_tags
}

### KEY VAULTS ###

module "key_vault" {
  source   = "../../modules/key_vault_private"
  for_each = toset(["INFRA", "DISKENC", "DATAENC"])

  name                        = "${local.prefix}-${each.key}-KV"
  resource_group_name         = azurerm_resource_group.this["KEYVAULT"].name
  location                    = var.location
  tenant_id                   = var.tenant_id
  enabled_for_disk_encryption = each.key == "DISKENC"

  role_assignments = {
    devops_agent = {
      principal_id         = module.devops_identity.principal_id
      role_definition_name = "Key Vault Administrator"
    }
  }

  private_endpoint_subnet_id           = module.vnet.subnet_ids["PrivateLink"]
  private_endpoint_resource_group_name = azurerm_resource_group.this["PRIVATELINK"].name
  private_dns_zone_ids                 = [local.central_dns_zone_ids["privatelink.vaultcore.azure.net"]]
  log_analytics_workspace_id           = local.log_analytics_workspace_id
  tags                                 = local.common_tags
}
