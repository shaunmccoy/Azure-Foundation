provider "azurerm" {
  # Required for plan/apply since azurerm 4.0. Can also be supplied through the
  # ARM_SUBSCRIPTION_ID environment variable (e.g. in CI), in which case leave
  # var.subscription_id unset.
  subscription_id = var.subscription_id

  # Use Entra ID (RBAC) instead of storage account shared keys for blob/queue
  # data-plane calls. Shared key access is disabled by default on many
  # tenants/policies, so this is the safer default for the storage module.
  storage_use_azuread = true

  # azurerm 5.x no longer registers Resource Providers by default
  # (resource_provider_registrations = "none"). If the subscription has not
  # had these registered already, uncomment the list below (requires
  # subscription-level */register/action permission).
  # resource_providers_to_register = [
  #   "Microsoft.Insights",
  #   "Microsoft.OperationalInsights",
  #   "Microsoft.Storage",
  # ]

  features {}
}
