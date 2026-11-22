variable "storage_account_name" {
  description="Specifies the name of the storage account."
}
variable "resource_group_name" {
  description="The name of the resource group in which to create the storage account."
}
variable "location" {
  description="Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}
variable "account_tier" {
  description="Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Standard and Premium."
}

variable "vnet_name" {
  description="The name of the virtual network that this storage account will allow access."
}

variable "subnet_name" {
  description="The name of the virtual network that this storage account will allow access."
}

variable "vnet_resource_group_name" {
  description="The name of the resource group that contains the VNET (eg. example-net-rg)"
}

variable "replication_type" {
}

variable "tla" {
  description = "The three letter acronym of the application."
}
variable "business_unit" {
  description = "The business unit associated with this application."
}

variable "cost_center" {
  description="The cost center associated with this application."
}
