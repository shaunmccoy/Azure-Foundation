locals {
  prefix         = local.hub_prefix
  subnet_type    = "private"
  resource_class = "hub"

  # Globally unique names (storage, registry) use the one-letter environment code to stay within length limits.
  storage_prefix = lower("${var.org_code}${local.env_code}hub${local.loc_code}")

  hosts_private_dns = length(var.private_dns_zones) > 0

  # Central private DNS zones live in one subscription (normally the production hub) and are
  # either created here or referenced by ID from the hub that hosts them.
  central_dns_zone_ids = {
    for zone in ["privatelink.vaultcore.azure.net", "privatelink.blob.core.windows.net", "privatelink.azurecr.io"] :
    zone => local.hosts_private_dns ? module.private_dns[0].zone_ids[zone] : provider::azurerm::normalise_resource_id(
      "/subscriptions/${var.private_dns_subscription_id}/resourceGroups/${var.private_dns_resource_group_name}/providers/Microsoft.Network/privateDnsZones/${zone}"
    )
  }
}
