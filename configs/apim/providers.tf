provider "azurerm" {
  subscription_id     = var.subscription_id
  tenant_id           = var.tenant_id
  storage_use_azuread = true

  resource_providers_to_register = [
    "Microsoft.ApiManagement",
    "Microsoft.Insights",
    "Microsoft.ManagedIdentity",
    "Microsoft.Network",
  ]

  features {
    api_management {
      # A destroyed service stays soft-deleted for 48 hours and can be recovered; never purge by default.
      purge_soft_delete_on_destroy = false
      recover_soft_deleted         = true
    }
  }
}
