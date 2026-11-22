variable resource_group_name {
  description = "Default resource group name that the database will be created in."
  default     = "myapp-rg"
}
variable location {
  description = "The location/region where the database and server are created. Changing this forces a new resource to be created."
}
variable db_name {
  description = "The name of the database to be created."
}
variable db_server_name {
  description ="The Name of the Database server name"
}
variable db_server_id {
  description = "This is id of database server"
}
variable db_edition {
  description = "The edition of the database to be created."
  default     = "Basic"
}
variable requested_service_objective_name {
  description = "The performance level for the database. For the list of acceptable values, see https://docs.microsoft.com/en-gb/azure/sql-database/sql-database-service-tiers. Default is Basic."
  default     = "Basic"
}
variable zone_redundant {
  description = "The performance level for the database. For the list of acceptable values, see https://docs.microsoft.com/en-gb/azure/sql-database/sql-database-service-tiers. Default is Basic."
  default     = true
}
variable collation {
  description = "The collation for the database. Default is SQL_Latin1_General_CP1_CI_AS"
  default     = "SQL_Latin1_General_CP1_CI_AS"
}
variable auditstore_primary_blob_endpoint {

}
variable auditstore_primary_access_key {
  
}
variable tags {
  description = "The tags to associate with your network and subnets."
  type        = (map)

  default = {
    tag1 = ""
    tag2 = ""
  }
}
