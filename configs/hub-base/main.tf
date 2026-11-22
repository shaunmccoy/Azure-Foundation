### RESOURCE GROUPS ###

locals {
  resource_groups = toset([
    "ACR", "ALERTS", "IDENTITIES", "IMAGEBUILD", "IMAGEGALLERY", "KEYVAULT",
    "LOGS", "NET", "PRIVATELINK", "STORAGE", "VAULT",
  ])
}

resource "azurerm_resource_group" "this" {
  for_each = local.resource_groups

  name     = "${local.prefix}-${each.key}-RG"
  location = var.location
  tags     = local.common_tags
}

### MONITORING AND SECURITY ###

module "log_analytics" {
  source = "../../modules/log_analytics"

  name                = local.hub_names.log_analytics_workspace
  resource_group_name = azurerm_resource_group.this["LOGS"].name
  location            = var.location
  retention_in_days   = 365
  tags                = local.common_tags
}

# Subscription activity log to Log Analytics (replaces the retired AzureActivity solution).
resource "azurerm_monitor_diagnostic_setting" "activity_log" {
  name                       = "LOGANALYTICS-ACTIVITY"
  target_resource_id         = "/subscriptions/${var.subscription_id}"
  log_analytics_workspace_id = module.log_analytics.id

  dynamic "enabled_log" {
    for_each = toset(["Administrative", "Security", "ServiceHealth", "Alert", "Recommendation", "Policy", "Autoscale", "ResourceHealth"])

    content {
      category = enabled_log.value
    }
  }
}

module "alert_rules" {
  source = "../../modules/alert_rules"

  resource_group_name = azurerm_resource_group.this["ALERTS"].name
  subscription_id     = var.subscription_id
  action_group_name   = "${local.loc_code}-${var.env} - L1 EMAIL ALERTS"
  email_address       = var.alert_email_group
  policy_alert_prefix = upper(var.org_code)
  tags                = local.common_tags
}

resource "azurerm_security_center_subscription_pricing" "this" {
  for_each = var.defender_plans

  tier          = "Standard"
  resource_type = each.value
}

resource "azurerm_security_center_workspace" "this" {
  scope        = "/subscriptions/${var.subscription_id}"
  workspace_id = module.log_analytics.id

  depends_on = [azurerm_security_center_subscription_pricing.this]
}

### MANAGED IDENTITY ###

module "devops_identity" {
  source = "../../modules/managed_identity"

  name                = local.hub_names.devops_identity
  resource_group_name = azurerm_resource_group.this["IDENTITIES"].name
  location            = var.location
  tags                = local.common_tags
}

### RECOVERY VAULT ###

module "recovery_vault" {
  source = "../../modules/recovery_vault"

  name                       = "${local.prefix}-RECOVER-VAULT-01"
  resource_group_name        = azurerm_resource_group.this["VAULT"].name
  location                   = var.location
  log_analytics_workspace_id = module.log_analytics.id
  tags                       = local.common_tags
}

### KEY VAULTS ###

module "key_vault" {
  source   = "../../modules/key_vault_private"
  for_each = toset(["INFRA", "DISKENCRYPT", "DATAENCRYPT"])

  name                        = "${local.prefix}-${each.key}-KV"
  resource_group_name         = azurerm_resource_group.this["KEYVAULT"].name
  location                    = var.location
  tenant_id                   = var.tenant_id
  enabled_for_disk_encryption = each.key == "DISKENCRYPT"

  role_assignments = {
    devops_agent = {
      principal_id         = module.devops_identity.principal_id
      role_definition_name = "Key Vault Administrator"
    }
  }

  private_endpoint_subnet_id           = module.vnet.subnet_ids["PrivateLink"]
  private_endpoint_resource_group_name = azurerm_resource_group.this["PRIVATELINK"].name
  private_dns_zone_ids                 = [local.central_dns_zone_ids["privatelink.vaultcore.azure.net"]]
  log_analytics_workspace_id           = module.log_analytics.id
  tags                                 = local.common_tags
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
  log_analytics_workspace_id           = module.log_analytics.id
  tags                                 = local.common_tags
}

### IMAGE GALLERY ###

module "image_gallery" {
  source = "../../modules/image_gallery"

  name                = "${local.loc_code}${upper(var.tla)}${local.env_code}IMAGEGALLERY"
  resource_group_name = azurerm_resource_group.this["IMAGEGALLERY"].name
  location            = var.location
  publisher           = upper(var.org_code)
  tags                = local.common_tags
}
