
resource "azurerm_cosmosdb_account" "db" {
  name                = var.cosmos_database_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = var.offer_type
  kind                = var.db_kind
  enable_free_tier    = var.enable_free_tier
  enable_automatic_failover = var.enable_automatic_failover
  enable_multiple_write_locations = var.enable_multiple_write_locations
  tags                = var.tags

  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.max_interval_in_seconds
    max_staleness_prefix    = var.max_staleness_prefix
  }

  geo_location {
    location          = var.failover_location
    failover_priority = var.failover_priority
  }

  geo_location {
    location          = var.replicated_data_location
    failover_priority = 0
  }

}