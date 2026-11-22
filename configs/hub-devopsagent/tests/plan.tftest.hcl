# Offline tests: run with `terraform test` (no Azure credentials needed).
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

variables {
  hub_subscription_id = "00000000-0000-0000-0000-000000000001"
  subscription_id     = "00000000-0000-0000-0000-000000000001"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
  env                 = "PROD"
  business_unit       = "INFR"
  cost_center         = "0000"
  location            = "centralus"
  tla                 = "HUB"

  agent_devops_url          = "https://dev.azure.com/example-org"
  agent_devops_project_name = "example-project"
  agent_pool_name           = "PROD-HUB-DEVOPS-AGENT-POOL"
  agent_scale_pool_name     = "PROD-HUB-SCALESET-POOL"
  agent_pat_token           = "not-a-real-token"
  scaleset_pat_token        = "not-a-real-token"

  img_subscription_id     = "00000000-0000-0000-0000-000000000005"
  img_resource_group_name = "CUS-HUB-X-IMAGEGALLERY-RG"
  img_gallery_name        = "CUSHUBXIMAGEGALLERY"
  img_name                = "DevOps-Agent-Ubuntu"
}

run "agents_and_scaleset" {
  command = plan

  assert {
    condition     = azurerm_resource_group.devops_agent.name == "CUS-HUB-P-DEVOPSAGENT-RG"
    error_message = "Unexpected resource group name."
  }

  assert {
    condition     = output.no_proxy == "203.0.113.0/24,0.0.0.0/0"
    error_message = "no_proxy must list the DevOps route table destinations."
  }

  assert {
    condition     = azurerm_resource_group.autoscale_agents[0].name == "CUS-HUB-P-AUTOSCALEAGENTS-RG"
    error_message = "Unexpected scale set resource group name."
  }

  assert {
    condition     = azurerm_key_vault_secret.agent_ssh_private_key.name == "SSHKEY-azdoagent-CUS-HUB-P-DEVOPSAGENT"
    error_message = "Unexpected SSH key secret name."
  }
}

run "scaleset_can_be_disabled" {
  command = plan

  variables {
    scaleset_enabled = false
  }

  assert {
    condition     = length(azurerm_resource_group.autoscale_agents) == 0 && length(module.autoscale_agents) == 0
    error_message = "Disabling the scale set must remove it and its resource group."
  }
}
