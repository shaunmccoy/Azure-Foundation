locals {
  prefix         = "${local.loc_code}-${upper(var.business_unit)}-${local.env_code}"
  subnet_type    = "private"
  resource_class = "app"

  # Globally unique names use the one-letter environment code to stay within length limits.
  storage_prefix = lower("${var.org_code}${local.env_code}${var.business_unit}${local.loc_code}")

  hub_vnet_id = provider::azurerm::normalise_resource_id(
    "/subscriptions/${var.hub_subscription_id}/resourceGroups/${local.hub_names.network_resource_group}/providers/Microsoft.Network/virtualNetworks/${local.hub_names.vnet}"
  )

  # Central private DNS zones, hosted by one hub for the whole estate.
  central_dns_zone_ids = {
    for zone in ["privatelink.vaultcore.azure.net", "privatelink.blob.core.windows.net"] :
    zone => provider::azurerm::normalise_resource_id(
      "/subscriptions/${var.private_dns_subscription_id}/resourceGroups/${var.private_dns_resource_group_name}/providers/Microsoft.Network/privateDnsZones/${zone}"
    )
  }

  # Subnet => extra route table, flattened from additional_route_tables.
  route_table_subnets = merge([
    for table, cfg in var.additional_route_tables : { for subnet in cfg.subnets : subnet => table }
  ]...)
}
