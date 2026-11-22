variable resource_group_name {
  description = "Resource group name that the database will be created in."
  default     = "myapp-rg"
}

variable location {
  description = "The location/region where the database and server are created. Changing this forces a new resource to be created."
}

variable server_version {
  description = "The version for the database server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server)."
  default     = "12.0"
}
variable zone_redundant {
  default = false
}
variable db_name {
  description = "The name of the database to be created."
}
variable db_server_name {
  description ="The Name of the Database server name"
}
variable db_edition {
  description = "The edition of the database to be created."
  default     = "Basic"
}

variable requested_service_objective_name {
  description = "The performance level for the database. For the list of acceptable values, see https://docs.microsoft.com/en-gb/azure/sql-database/sql-database-service-tiers. Default is Basic."
  default     = "Basic"
}

variable collation {
  description = "The collation for the database. Default is SQL_Latin1_General_CP1_CI_AS"
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable sql_administrator_login {
  description = "The administrator username of the SQL Server."
}

variable sql_administrator_login_password {
  description = "The administrator password of the SQL Server."
}

variable connection_policy {
  description = "The administrator password of the SQL Server."
}
variable start_ip_address {
  description = "Defines the start IP address used in your database firewall rule."
  default     = "0.0.0.0"
}

variable end_ip_address {
  description = "Defines the end IP address used in your database firewall rule."
  default     = "0.0.0.0"
}
variable sql_audit_storage_name  {
  description = "Name of the storage for audit log"
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
