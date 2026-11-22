### CENTRAL PRIVATE DNS ###
# One hub hosts the privatelink zones for the whole estate and links every hub virtual network
# to them. Private endpoints anywhere register themselves through private DNS zone groups, so
# there are no hand-maintained A records.

resource "azurerm_resource_group" "private_dns" {
  count = local.hosts_private_dns ? 1 : 0

  name     = "${local.prefix}-PRIVATEDNS-RG"
  location = var.location
  tags     = local.common_tags
}

module "private_dns" {
  source = "../../modules/private_dns"
  count  = local.hosts_private_dns ? 1 : 0

  resource_group_name = azurerm_resource_group.private_dns[0].name
  zones               = var.private_dns_zones
  tags                = local.common_tags

  virtual_network_links = merge(
    { (lower(module.vnet.name)) = module.vnet.id },
    var.private_dns_linked_vnet_ids,
  )
}
