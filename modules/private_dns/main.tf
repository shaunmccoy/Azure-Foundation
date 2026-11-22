locals {
  # One link per zone per virtual network.
  links = merge([
    for zone in var.zones : {
      for link_name, vnet_id in var.virtual_network_links :
      "${zone}/${link_name}" => { zone = zone, link_name = link_name, vnet_id = vnet_id }
    }
  ]...)
}

resource "azurerm_private_dns_zone" "this" {
  for_each = var.zones

  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = local.links

  name                 = each.value.link_name
  private_dns_zone_id  = azurerm_private_dns_zone.this[each.value.zone].id
  virtual_network_id   = each.value.vnet_id
  registration_enabled = false
  tags                 = var.tags
}
