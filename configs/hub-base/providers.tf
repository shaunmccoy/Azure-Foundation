provider "azurerm" {
  subscription_id     = var.subscription_id
  tenant_id           = var.tenant_id
  storage_use_azuread = true

  # azurerm 5.x registers no resource providers by default; list what this config needs.
  resource_providers_to_register = [
    "Microsoft.Compute",
    "Microsoft.ContainerRegistry",
    "Microsoft.Insights",
    "Microsoft.KeyVault",
    "Microsoft.ManagedIdentity",
    "Microsoft.Network",
    "Microsoft.OperationalInsights",
    "Microsoft.OperationsManagement",
    "Microsoft.RecoveryServices",
    "Microsoft.Security",
    "Microsoft.SecurityInsights",
    "Microsoft.Storage",
  ]

  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}
