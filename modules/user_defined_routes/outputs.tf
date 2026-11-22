output "id" {
  description = "Route table resource ID."
  value       = azurerm_route_table.this.id
}

output "name" {
  description = "Route table name."
  value       = azurerm_route_table.this.name
}

output "route_address_prefixes" {
  description = "Every destination CIDR that has an explicit route in this table."
  value       = concat(var.internet_route_cidrs, var.black_hole_route_cidrs)
}
