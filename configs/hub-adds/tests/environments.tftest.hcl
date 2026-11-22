# Plans every environments/*.tfvars file against a mocked provider (scripts/validate.sh
# passes each file with -var-file). Secrets that normally arrive as TF_VAR_* get dummy values.
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

run "plans_with_environment_file" {
  command = plan
}
