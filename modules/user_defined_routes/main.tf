resource "azurerm_route_table" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = var.bgp_route_propagation_enabled
  tags                          = var.tags
}

# Routes are keyed by CIDR, so adding or removing one never renumbers the rest.
resource "azurerm_route" "internet" {
  for_each = toset(var.internet_route_cidrs)

  name                = "INTERNET-${replace(each.value, "/[./]/", "-")}"
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.this.name
  address_prefix      = each.value
  next_hop_type       = "Internet"
}

resource "azurerm_route" "black_hole" {
  for_each = toset(var.black_hole_route_cidrs)

  name                = "BLACK-HOLE-${replace(each.value, "/[./]/", "-")}"
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.this.name
  address_prefix      = each.value
  next_hop_type       = "None"
}

resource "azurerm_route" "default" {
  name                   = "DefaultRoute"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.this.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = var.default_next_hop_type
  next_hop_in_ip_address = var.default_next_hop_ip_address
}
