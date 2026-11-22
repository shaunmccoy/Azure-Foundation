# General variables
variable resource_group_name {
  description="The name of the resource group in which to create the storage account."
}
variable location {
}
variable tags {
  default = {}
}
## Cosmos database creation variables
variable cosmos_database_account_name {
}
variable offer_type {
  default = "Standard"
}
variable db_kind {
  default = "GlobalDocumentDB"
}
variable enable_free_tier  {
  default = "false"
}
variable enable_automatic_failover  {
  default = "true"
}
variable enable_multiple_write_locations  {
  default = "true"
}
variable consistency_level  {
  default = "BoundedStaleness"
}
variable max_interval_in_seconds  {
  default = "5"
}
variable max_staleness_prefix  {
  default = "100"
}
variable failover_location  {
}
variable replicated_data_location  {
}
variable failover_priority  {
  default = "1"
}
/*
# For privatendpoint these variables are needed
variable "vnet_name" {
  description="The name of the virtual network that this storage account will allow access."
}
variable "private_endpoint_name" {
  description="The name of the private endpoint to be created"
}
variable "vnet_resource_group_name" {
  description="The name of the resource group that contains the VNET (eg. example-net-rg)"
}
variable "subnet_name" {
  description="The name of the subnet to which private end point will be created "
  
}
variable "subresource_name" {
    description ="Type of resource to be used in endpoint creation e.g. blob"
}
*/