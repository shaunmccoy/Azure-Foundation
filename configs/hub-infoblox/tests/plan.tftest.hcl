# Offline tests: run with `terraform test` (no Azure credentials needed).
mock_provider "azurerm" {}

# Stand-ins for the hub-base resources this config looks up.

override_data {
  target = data.azurerm_subnet.infoblox
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/CUS-HUB-P-NET-RG/providers/Microsoft.Network/virtualNetworks/CUS-HUB-P-VNET/subnets/InfoBlox"
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
  business_unit       = "INFR"
  cost_center         = "0000"
  location            = "centralus"
  tla                 = "ddi"

  infoblox_image = {
    offer = "example-offer"
    sku   = "example-sku"
  }

  infoblox_vms = [
    { ip_address = "10.100.64.36", zone = "1" },
    { ip_address = "10.100.64.37", zone = "2" },
  ]
}

run "appliances_without_grid" {
  command = plan

  assert {
    condition     = output.appliances == { CUSHUBPINFOBLOX01 = "10.100.64.36", CUSHUBPINFOBLOX02 = "10.100.64.37" }
    error_message = "Unexpected appliance names or addresses."
  }

  assert {
    condition     = azurerm_network_interface.infoblox["02"].name == "CUS-HUB-P-INFOBLOX-NIC02"
    error_message = "Unexpected NIC name."
  }

  assert {
    condition     = length(azurerm_network_security_rule.infoblox) == 4
    error_message = "Grid rules must not exist when no grid members are listed."
  }

  assert {
    condition     = length(azurerm_marketplace_agreement.infoblox) == 0
    error_message = "Marketplace terms must only be accepted on request."
  }
}

run "grid_members_open_grid_ports" {
  command = plan

  variables {
    grid_member_addresses    = ["192.168.10.1", "192.168.10.220"]
    accept_marketplace_terms = true
  }

  assert {
    condition     = length(azurerm_network_security_rule.infoblox) == 6
    error_message = "Expected the two grid rules in addition to the four virtual network rules."
  }

  assert {
    condition     = toset(azurerm_network_security_rule.infoblox["UDP-1194-Inbound-INFOBLOX"].source_address_prefixes) == toset(["192.168.10.1", "192.168.10.220"])
    error_message = "Grid rules must be limited to the grid members."
  }

  assert {
    condition     = azurerm_network_security_rule.infoblox["TCP-53-Inbound-INFOBLOX"].source_address_prefix == "VirtualNetwork"
    error_message = "DNS must be allowed from the virtual network."
  }

  assert {
    condition     = azurerm_marketplace_agreement.infoblox[0].plan == "example-sku"
    error_message = "Marketplace agreement must match the image plan."
  }
}
