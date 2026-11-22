provider "azurerm" {
  subscription_id     = var.subscription_id
  tenant_id           = var.tenant_id
  storage_use_azuread = true

  resource_providers_to_register = [
    "Microsoft.Compute",
    "Microsoft.Insights",
    "Microsoft.KeyVault",
    "Microsoft.ManagedIdentity",
    "Microsoft.Network",
    "Microsoft.Security",
    "Microsoft.Storage",
  ]

  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

# The hub this spoke peers with. Used only for the hub side of the peering.
provider "azurerm" {
  alias               = "hub"
  subscription_id     = var.hub_subscription_id
  tenant_id           = var.tenant_id
  storage_use_azuread = true

  features {}
}
