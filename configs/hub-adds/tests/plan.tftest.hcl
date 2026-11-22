# Offline tests: run with `terraform test` (no Azure credentials needed).
mock_provider "azurerm" {}

# Stand-ins for the hub-base resources this config looks up.
override_data {
  target = data.azurerm_subnet.active_directory
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/CUS-HUB-P-NET-RG/providers/Microsoft.Network/virtualNetworks/CUS-HUB-P-VNET/subnets/ActiveDirectory"
  }
}

override_data {
  target = data.azurerm_key_vault.infra
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/CUS-HUB-P-KEYVAULT-RG/providers/Microsoft.KeyVault/vaults/CUS-HUB-P-INFRA-KV"
  }
}

variables {
  hub_subscription_id = "00000000-0000-0000-0000-000000000001"
  subscription_id     = "00000000-0000-0000-0000-000000000001"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
  env                 = "PROD"
  tla                 = "wdc"
  business_unit       = "INFR"
  cost_center         = "0000"
  location            = "centralus"

  adds_vms = [
    { ip_address = "10.100.64.4", zone = "1" },
    { ip_address = "10.100.64.5", zone = "2" },
  ]
}

run "domain_controllers" {
  command = plan

  assert {
    condition     = output.domain_controllers == { CUSWDCP001 = "10.100.64.4", CUSWDCP002 = "10.100.64.5" }
    error_message = "Unexpected domain controller names or addresses."
  }

  assert {
    condition     = azurerm_windows_virtual_machine.adds["CUSWDCP002"].zone == "2" && azurerm_managed_disk.adds["CUSWDCP002"].zone == "2"
    error_message = "A domain controller and its data disk must be in the same zone."
  }

  assert {
    condition     = azurerm_resource_group.adds.name == "CUS-HUB-P-ADDS-RG"
    error_message = "Unexpected resource group name."
  }

  assert {
    condition     = length(azurerm_network_security_rule.adds) == 18
    error_message = "Expected the 18 Active Directory inbound rules."
  }

  assert {
    condition     = azurerm_key_vault_secret.admin_password["CUSWDCP001"].name == "PASSWORD-azadmin-CUSWDCP001"
    error_message = "Unexpected password secret name."
  }

  assert {
    condition     = azurerm_windows_virtual_machine.adds["CUSWDCP001"].tags["org:operatingSystem"] == "windows"
    error_message = "The operatingSystem tag must use the org_code namespace."
  }
}

run "rejects_bad_ip" {
  command = plan

  variables {
    adds_vms = [{ ip_address = "10.100.64" }]
  }

  expect_failures = [var.adds_vms]
}
