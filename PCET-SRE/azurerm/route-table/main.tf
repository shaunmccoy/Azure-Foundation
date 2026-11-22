data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_route_table" "udr" {
  name                          = var.route_table_name
  location                      = data.azurerm_resource_group.rg.location
  resource_group_name           = data.azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  tags = var.tags
  
  dynamic "route" {
    for_each = var.route_table.route_entries
    content {
      name                   = route.value.name
      address_prefix         = route.value.prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_type == "VirtualAppliance" ? (var.next_hop_in_dynamic_private_ip != null && var.next_hop_in_dynamic_private_ip != "null" && var.next_hop_in_dynamic_private_ip != "" ? var.next_hop_in_dynamic_private_ip : route.value.next_hop_in_ip_address) : null
    }
  }
}
