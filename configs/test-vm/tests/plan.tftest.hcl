# Offline tests: run with `terraform test` (no Azure credentials needed).
mock_provider "azurerm" {}

# Stand-ins for the hub-base resources this config looks up.

override_data {
  target = data.azurerm_key_vault.infra
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/CUS-HUB-P-KEYVAULT-RG/providers/Microsoft.KeyVault/vaults/CUS-HUB-P-INFRA-KV"
  }
}

override_data {
  target = data.azurerm_subnet.private_endpoint
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/CUS-HUB-P-NET-RG/providers/Microsoft.Network/virtualNetworks/CUS-HUB-P-VNET/subnets/PrivateLink"
  }
}

variables {
  hub_subscription_id = "00000000-0000-0000-0000-000000000001"
  subscription_id     = "00000000-0000-0000-0000-000000000001"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
  env                 = "PROD"
  business_unit       = "INFR"
  cost_center         = "0000"
  location            = "centralus"
  tla                 = "azr"
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/CUS-HUB-P-NET-RG/providers/Microsoft.Network/virtualNetworks/CUS-HUB-P-VNET/subnets/Management"
}

run "vms_only" {
  command = plan

  assert {
    condition     = azurerm_resource_group.testers.name == "CUS-PROD-TEST-RG"
    error_message = "Unexpected resource group name."
  }

  assert {
    condition     = azurerm_windows_virtual_machine.windows.computer_name == "CUSPTESTWIN"
    error_message = "Unexpected Windows computer name."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.linux.disable_password_authentication
    error_message = "The Linux test VM must only accept SSH keys."
  }

  assert {
    condition     = length(azurerm_cognitive_account.test) == 0 && length(azurerm_private_endpoint.cognitive) == 0
    error_message = "The private-link test target must be opt-in."
  }
}

run "with_private_link_target" {
  command = plan

  variables {
    cognitive_service = {
      vnet_name                = "CUS-HUB-P-VNET"
      vnet_resource_group_name = "CUS-HUB-P-NET-RG"
    }
  }

  assert {
    condition     = azurerm_cognitive_account.test[0].custom_subdomain_name == "cus-prod-cogservice"
    error_message = "Unexpected custom subdomain."
  }

  assert {
    condition     = !azurerm_cognitive_account.test[0].public_network_access_enabled
    error_message = "The test target must not be publicly reachable."
  }
}
