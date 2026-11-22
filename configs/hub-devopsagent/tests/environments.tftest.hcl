# Plans every environments/*.tfvars file against a mocked provider (scripts/validate.sh
# passes each file with -var-file). Secrets that normally arrive as TF_VAR_* get dummy values.
mock_provider "azurerm" {}

mock_provider "azurerm" {
  alias = "img"
}

# Stand-ins for the hub-base resources this config looks up.

override_data {
  target = data.azurerm_subnet.devops_agents
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/CUS-HUB-P-NET-RG/providers/Microsoft.Network/virtualNetworks/CUS-HUB-P-VNET/subnets/DevOpsAgents"
  }
}

override_data {
  target = data.azurerm_key_vault.infra
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/CUS-HUB-P-KEYVAULT-RG/providers/Microsoft.KeyVault/vaults/CUS-HUB-P-INFRA-KV"
  }
}

override_data {
  target = data.azurerm_user_assigned_identity.devops
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/CUS-HUB-P-IDENTITIES-RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/CUS-HUB-P-IDENTITY-DEVOPSAGENT"
  }
}

override_data {
  target = data.azurerm_shared_image.agent
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000005/resourceGroups/CUS-HUB-X-IMAGEGALLERY-RG/providers/Microsoft.Compute/galleries/CUSHUBXIMAGEGALLERY/images/DevOps-Agent-Ubuntu"
  }
}

override_data {
  target = data.azurerm_route_table.devops
  values = {
    route = [
      { name = "INTERNET-203-0-113-0-24", address_prefix = "203.0.113.0/24", next_hop_type = "Internet", next_hop_in_ip_address = "" },
      { name = "DefaultRoute", address_prefix = "0.0.0.0/0", next_hop_type = "Internet", next_hop_in_ip_address = "" },
    ]
  }
}

run "plans_with_environment_file" {
  command = plan

  variables {
    agent_pat_token    = "test-only"
    scaleset_pat_token = "test-only"
  }
}
