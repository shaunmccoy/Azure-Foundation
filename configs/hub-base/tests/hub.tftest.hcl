# Offline tests: no Azure credentials needed. scripts/validate.sh runs them once per
# environments/*.tfvars file; by hand: terraform test -var-file=environments/CUS-PROD.tfvars
mock_provider "azurerm" {}

run "plans_with_environment_file" {
  command = plan

  assert {
    condition     = azurerm_resource_group.this["NET"].name == "${upper(var.loc_code[var.location])}-HUB-${var.env_code[var.env]}-NET-RG"
    error_message = "Unexpected network resource group name."
  }

  assert {
    condition     = length(azurerm_resource_group.private_dns) == (length(var.private_dns_zones) > 0 ? 1 : 0)
    error_message = "Only the hub that lists private_dns_zones hosts the central private DNS resource group."
  }

  assert {
    condition     = azurerm_container_registry.this.admin_enabled == false && azurerm_container_registry.this.public_network_access_enabled == false
    error_message = "The container registry must have no admin account and no public access."
  }

  assert {
    condition     = alltrue([for vault in module.key_vault : length(vault.name) <= 24])
    error_message = "Key Vault names must fit in 24 characters."
  }
}

run "rejects_hub_without_gateway_subnet" {
  command = plan

  variables {
    subnets = {
      PrivateLink = { address_prefixes = ["10.100.78.0/24"] }
    }
  }

  expect_failures = [var.subnets]
}

run "rejects_vpn_without_shared_key" {
  command = plan

  variables {
    vpn = {
      onprem_gateway_address = "203.0.113.10"
      onprem_address_space   = ["192.168.0.0/16"]
    }
    vpn_shared_key = "too-short"
  }

  expect_failures = [var.vpn_shared_key]
}
