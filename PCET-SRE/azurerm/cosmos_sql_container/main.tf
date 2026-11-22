resource "azurerm_cosmosdb_sql_container" "container" {
  count = length(var.cosmos_container_name)
  name                = var.cosmos_container_name[count.index]
  resource_group_name = var.resource_group_name
  account_name        = var.cosmos_database_account_name
  database_name       = var.cosmos_database_name
  partition_key_path  = var.container_partition_key
  throughput          = 400

  indexing_policy {
    indexing_mode = "Consistent"

    included_path {
      path = "/*"
    }

    excluded_path {
      path = "/\"_etag\"/?"
    }
  }

  unique_key {
    paths = ["/definition/idlong", "/definition/idshort"]
  }
}