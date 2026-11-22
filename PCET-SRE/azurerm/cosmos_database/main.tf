resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

data "azurerm_virtual_network" "vnet" {
  name = var.vnet_name
  resource_group_name = var.vnet_resource_group_name
}
data "azurerm_subnet" "subnet" {
 
  #count = length(data.azurerm_virtual_network.vnet.subnets)
  
  name =  var.subnet_name#data.azurerm_virtual_network.vnet.subnets[count.index]
  virtual_network_name = var.vnet_name
  resource_group_name = var.vnet_resource_group_name
}

resource "azurerm_cosmosdb_account" "db" {
  name                = var.cosmos_database_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = var.offer_type
  kind                = var.db_kind
  # enable_free_tier    = var.enable_free_tier
  enable_automatic_failover = var.enable_automatic_failover
  enable_multiple_write_locations = var.enable_multiple_write_locations
  tags                = var.tags

  consistency_policy {
    consistency_level       = var.consistency_level #"BoundedStaleness"
    max_interval_in_seconds = var.max_interval_in_seconds #10
    max_staleness_prefix    = var.max_staleness_prefix  #200
  }

  geo_location {
    location          = var.failover_location
    failover_priority = var.failover_priority
  }

  geo_location {
   # prefix            = "cosmosdb-${var.cosmos_database_account_name.name}-${random_integer.ri.result}"
    location          = var.replicated_data_location
    failover_priority = 0
  }

}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = var.cosmos_database_name
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
  throughput          = 400
}
