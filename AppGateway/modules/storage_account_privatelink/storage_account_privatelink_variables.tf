variable "resource_group_name" {
  description = "Resource Group Name"
}

variable resource_tags {
  type = (map)
}

variable "storage_name" {
  description = "Name of the Storage Account Name"
}

variable "storage_usage" {
  description = "Allowed values: blob, web, file, queue, table"
  default     = "blob"
}

variable "account_replication_type" {
   description = "Account Replication Type-Options: LRS, GRS, RAGRS and ZRS."
   default     = "LRS"
}

variable "account_tier" {
   description = "Account Tier Type-Options: Standard and Premium."
   default     = "Standard"
}

variable "allow_azure_services" {
  description = "If set to true, enable Azure Services"
  type        = bool
  default     = false
}

variable "virtual_network_subnet_ids" {
  type    = list
	default = []
}

variable "web_index_document" {
	default = ""
}
variable "error_404_document" {
	default = ""
}
variable "allow_blob_public_access" {
    type = bool
	default = false
}

variable "privatelink_resource_group_name" {
  default = ""
}

variable "vnet_resource_group_name" {
  default = ""
}

variable "vnet_name" {
  default = ""
}

# TODO Variable not used -- should be removed.
variable log_retention_policy_days {
   default = 365
}

variable log_analytics_workspace_id {

}

