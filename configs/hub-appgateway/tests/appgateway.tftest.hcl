# Offline tests: no Azure credentials needed. scripts/validate.sh runs them once per environment file.
mock_provider "azurerm" {
  mock_data "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/CUS-HUB-P-NET-RG/providers/Microsoft.Network/virtualNetworks/CUS-HUB-P-VNET/subnets/AppGateway"
    }
  }

  mock_data "azurerm_key_vault" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/CUS-HUB-P-KEYVAULT-RG/providers/Microsoft.KeyVault/vaults/CUS-HUB-P-INFRA-KV"
    }
  }

  mock_resource "azurerm_user_assigned_identity" {
    defaults = {
      id           = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/CUS-HUB-P-APP-GATEWAY-RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/CUS-HUB-P-IDENTITY-APPGATEWAY"
      principal_id = "00000000-0000-0000-0000-0000000000aa"
    }
  }
}

run "plans_with_environment_file" {
  command = plan

  assert {
    condition     = azurerm_resource_group.app_gateway.name == "${upper(var.loc_code[var.location])}-HUB-${var.env_code[var.env]}-APP-GATEWAY-RG"
    error_message = "Unexpected resource group name."
  }

  assert {
    condition     = alltrue([for l in values(var.listeners) : l.protocol == "Https" || contains([for r in values(var.routing_rules) : r.listener_name if r.redirect_to_listener != null], "http")])
    error_message = "Plain HTTP listeners must only redirect to HTTPS."
  }
}

run "rejects_https_listener_without_certificate" {
  command = plan

  variables {
    listeners = {
      https = { port = 443 }
    }
  }

  expect_failures = [var.listeners]
}
