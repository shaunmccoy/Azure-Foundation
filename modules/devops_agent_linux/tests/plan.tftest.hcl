# Offline tests: run with `terraform test` (no Azure credentials needed).
mock_provider "azurerm" {}

variables {
  num_agents                 = 4
  resource_group_name        = "CUS-HUB-P-DEVOPSAGENT-RG"
  location                   = "centralus"
  subnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/CUS-HUB-P-NET-RG/providers/Microsoft.Network/virtualNetworks/CUS-HUB-P-VNET/subnets/DevOpsAgents"
  nsg_name                   = "CUS-HUB-P-DEVOPSAGENT-NSG"
  vm_name_prefix             = "CUSHUBP"
  admin_ssh_public_key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDC00XEI5VCmFXFK1sAlwyqplfsAVrVlcTbfKniERa84eNUm1np1Gx0f2fKvnsIxWiATaJXUxZLxLGR9WQseZZXRe6g8c+W3PVKOq6IpFjOgKhNd+XQ6cndRI3xyiB734HTh9zgWn4RKMwL4gDLm1cTFHEZYrWqIf9bV+INnxOzpYX/B5I0awDA2ucmiucmuJpJX9YWIJwKXame0NubamY15+bvCfMY8O+h2VwO0C3kmUKP3WPgKq8Nce5UW9/8rd5dpAFnbbu0KWQt62RW6WyKDK78nwHuoKRt6gXKcqp8Uckw+XU/sanzJJcSNXWbSKjiDvslPKe9hvIi1rfOKfvx test-only" # throw-away key; the private half was never kept
  devops_url                 = "https://dev.azure.com/example-org"
  devops_project_name        = "example-project"
  agent_pool_name            = "example-pool"
  agent_pat_token            = "not-a-real-token"
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/CUS-HUB-P-LOGS-RG/providers/Microsoft.OperationalInsights/workspaces/CUS-HUB-P-AZLOGANALYTICS"
}

run "zone_spread_and_naming" {
  command = plan

  assert {
    condition     = [for key in ["01", "02", "03", "04"] : azurerm_linux_virtual_machine.agents[key].zone] == ["1", "2", "3", "1"]
    error_message = "Agents must be spread across the zones in turn."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.agents["01"].name == "CUSHUBPDEVAGT01"
    error_message = "Unexpected VM name."
  }

  assert {
    condition     = strcontains(base64decode(local.custom_data["01"]), "vsts-agent-linux-x64-$AGENT_VERSION.tar.gz") && strcontains(base64decode(local.custom_data["01"]), "AGENT_VERSION=\"5.283.1\"")
    error_message = "The init script must install the default agent version."
  }

  assert {
    condition     = !strcontains(base64decode(local.custom_data["01"]), "http_proxy")
    error_message = "No proxy settings may be written when no proxy is configured."
  }
}

run "proxy_and_rhel" {
  command = plan

  variables {
    num_agents    = 1
    zones         = []
    linux_dialect = "rhel"
    https_proxy   = "http://proxy.example.com:3128"
    no_proxy      = "10.0.0.0/8"
    agent_version = null
  }

  assert {
    condition     = azurerm_linux_virtual_machine.agents["01"].zone == null
    error_message = "No zone may be set when zones is empty."
  }

  assert {
    condition     = strcontains(base64decode(local.custom_data["01"]), "https_proxy=http://proxy.example.com:3128") && strcontains(base64decode(local.custom_data["01"]), "no_proxy=10.0.0.0/8,169.254.169.254,168.63.129.16")
    error_message = "Proxy settings must reach the init script."
  }

  assert {
    condition     = strcontains(base64decode(local.custom_data["01"]), "dnf -y install")
    error_message = "The rhel dialect must use the RHEL init script."
  }
}

run "rejects_unknown_dialect" {
  command = plan

  variables {
    linux_dialect = "centos"
  }

  expect_failures = [var.linux_dialect]
}
