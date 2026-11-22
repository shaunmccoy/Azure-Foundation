variable "resource_group_name" {
  description="The name of the resource group in which to create the storage account."
}
variable "location" {
  description="Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}
variable "vnet_name" {
  description="The name of the virtual network that this storage account will allow access."
}

variable "vnet_resource_group_name" {
  description="The name of the resource group that contains the VNET (eg. example-net-rg)"
}
variable "subnet_name" {
  description="The name of the subnet to which private end point will be created "
}

variable "tags" {
  default = {}
  description="The name of the resource group in which to create the storage account."
}
## Cosmos database creation variables
variable "cosmos_database_account_name"{
  description = "name of cosmos database"
}
variable "offer_type"{
  default = "Standard"
  description = "name of cosmos database"
}
variable "db_kind"{
  default = "GlobalDocumentDB"
  description = "name of cosmos database"
}
variable "enable_free_tier"{
  default = "false"
  description = "name of cosmos database"
}
variable "enable_automatic_failover"{
  default = "true"
  description = "name of cosmos database"
}
variable "enable_multiple_write_locations"{
  default = "true"
  description = "name of cosmos database"
}
variable "consistency_level"{
  default = "BoundedStaleness"
  description = "name of cosmos database"
}
variable "max_interval_in_seconds"{
  default = "5"
  description = "name of cosmos database"
}
variable "max_staleness_prefix"{
  default = "100"
  description = "name of cosmos database"
}
variable "failover_location"{
  description = "name of cosmos database"
}
variable "replicated_data_location"{
  description = "name of cosmos database"
}
variable "failover_priority"{
  default = "1"
  description = "name of cosmos database"
}

variable "cosmos_database_name" {}