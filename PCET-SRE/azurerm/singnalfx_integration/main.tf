provider "signalfx" {
  auth_token = var.signalfx_auth_token
  api_url = var.signalfx_api_url
  version = "~> 4.23"
}

provider "azurerm" {
  version = ">=2.0.0"
  features{}
  client_id       = "10000000-0000-0000-0000-000000000006"
  client_secret   = "REPLACE_ME"
  tenant_id       = "00000000-0000-0000-0000-000000000000"
}

resource "signalfx_azure_integration" "azure-signalfx-integration" {
    name = var.name
    enabled = var.enabled
    poll_rate = var.poll_rate
    secret_key = var.secret_key
    app_id = var.app_id
    tenant_id = var.tenant_id
    services = var.services
    subscriptions = var.subscriptions
}

data "azurerm_client_config" "main" {}

data "azurerm_role_definition" "main" {
  count = var.role != "" ? 1 : 0
  name  = var.role
}
data "azurerm_subscription" "main" {}

resource "azurerm_role_assignment" "role_assignment" {
  count                = var.role != "" ? length(local.scopes) : 0
  scope                = "/subscriptions/${var.subscriptions[count.index]}"
  role_definition_id   = format("%s%s", data.azurerm_subscription.main.id, data.azurerm_role_definition.main[0].id)
  principal_id         = var.object_id
}
