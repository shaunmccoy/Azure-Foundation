# Offline tests: no Azure credentials needed. scripts/validate.sh runs them once per environment file.
mock_provider "azurerm" {}

mock_provider "azurerm" {
  alias = "hub"
}

run "plans_with_environment_file" {
  command = plan

  assert {
    condition     = alltrue([for account in module.storage : length(account.name) <= 24])
    error_message = "Storage account names must fit in 24 characters."
  }

  assert {
    condition     = alltrue([for vault in module.key_vault : length(vault.name) <= 24])
    error_message = "Key Vault names must fit in 24 characters."
  }

  assert {
    condition     = azurerm_virtual_network_peering.spoke_to_hub.use_remote_gateways == true
    error_message = "Spokes should reach on-premises through the hub gateway."
  }

  assert {
    condition     = length(setintersection(keys(azurerm_subnet_route_table_association.default), keys(azurerm_subnet_route_table_association.additional))) == 0
    error_message = "A subnet can only be attached to one route table."
  }
}

run "plans_with_scale_set_agents" {
  command = plan

  variables {
    scaleset_pat_token = "test-only"
    agent_scaleset = {
      image_id            = "/subscriptions/00000000-0000-0000-0000-000000000005/resourceGroups/CUS-HUB-X-IMAGEGALLERY-RG/providers/Microsoft.Compute/galleries/CUSHUBXIMAGEGALLERY/images/DevOps-Agent-Ubuntu"
      devops_url          = "https://dev.azure.com/example-org"
      devops_project_name = "example-project"
      pool_name           = "TEST-SCALESET-POOL"
      # Throwaway public key generated for this test; its private half was never stored.
      ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDK7iYEVNLm1xhUVbNvpwnPyUWzu2k7O1/sylFKPXcx2tLfm8xj48MMgZ05whpp8IGFScdmHhmchsileQTCyNLIt7F4IDUpfB23E0073TSsYSyu1fK/rM9Tw1BjY+/LDGntOSbOMkQNerUyLP0GQXDXq2M5MGtIcb1Bo2M6gJgeztE6atf951+idkzLn8jOXWXKPdn3kPbe4YzxNmk4eKiO5QKY5m08wT61yXklXfkeYwBrV2xTDfRBRPZLXzKjpq478KzwBiXVNCFMWH7OWlypD0f48V9a4vsrF0Ywy0cBS/2x1P2BQg5Njv0wOAFfKlXJPJ7W/w8M5b6YHbmZFXcmacOK+R0XFMRuyRtPx8b08JW6mDsTiO/BNAtRdlxmP/62FcN3PsJqigBr92jOmSGViApCIal48h3NNaXDPAV3/osSQZN3ps39ZqvmyDJXxB63NAX2mIUecb8exM7KMZ3UZOT/FYyAHgaKutAAqNA4AnvjcfSYpWi1aP//s5MrJ0mA0YTm6yosMzUOOYi5ppElTaqf7vvSC1huOtZx4ow8BTYhn09qgggPcSML2HGYGtm8nx9kcpU4yKWkPU/+PgcFm9YUQLETUr5zUnmDRhbJzGg+HLQ2pobutruHPRjyeOmFddsbN1d6FJuoXFp7ReKb9lFPgC2PelH8ywDRCbB7MQ== test-only"
    }
  }

  assert {
    condition     = length(module.autoscale_agents) == 1
    error_message = "The scale set should be created when agent_scaleset is set."
  }
}

run "rejects_spoke_without_privatelink_subnet" {
  command = plan

  variables {
    subnets = {
      Application = { address_prefixes = ["10.102.20.64/27"] }
    }
  }

  expect_failures = [var.subnets]
}

run "rejects_scale_set_without_token" {
  command = plan

  variables {
    agent_scaleset = {
      image_id            = "/subscriptions/00000000-0000-0000-0000-000000000005/resourceGroups/CUS-HUB-X-IMAGEGALLERY-RG/providers/Microsoft.Compute/galleries/CUSHUBXIMAGEGALLERY/images/DevOps-Agent-Ubuntu"
      devops_url          = "https://dev.azure.com/example-org"
      devops_project_name = "example-project"
      pool_name           = "TEST-SCALESET-POOL"
      ssh_public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDK7iYEVNLm1xhUVbNvpwnPyUWzu2k7O1/sylFKPXcx2tLfm8xj48MMgZ05whpp8IGFScdmHhmchsileQTCyNLIt7F4IDUpfB23E0073TSsYSyu1fK/rM9Tw1BjY+/LDGntOSbOMkQNerUyLP0GQXDXq2M5MGtIcb1Bo2M6gJgeztE6atf951+idkzLn8jOXWXKPdn3kPbe4YzxNmk4eKiO5QKY5m08wT61yXklXfkeYwBrV2xTDfRBRPZLXzKjpq478KzwBiXVNCFMWH7OWlypD0f48V9a4vsrF0Ywy0cBS/2x1P2BQg5Njv0wOAFfKlXJPJ7W/w8M5b6YHbmZFXcmacOK+R0XFMRuyRtPx8b08JW6mDsTiO/BNAtRdlxmP/62FcN3PsJqigBr92jOmSGViApCIal48h3NNaXDPAV3/osSQZN3ps39ZqvmyDJXxB63NAX2mIUecb8exM7KMZ3UZOT/FYyAHgaKutAAqNA4AnvjcfSYpWi1aP//s5MrJ0mA0YTm6yosMzUOOYi5ppElTaqf7vvSC1huOtZx4ow8BTYhn09qgggPcSML2HGYGtm8nx9kcpU4yKWkPU/+PgcFm9YUQLETUr5zUnmDRhbJzGg+HLQ2pobutruHPRjyeOmFddsbN1d6FJuoXFp7ReKb9lFPgC2PelH8ywDRCbB7MQ== test-only"
    }
  }

  expect_failures = [var.scaleset_pat_token]
}
