variable "storage_account_name" {
  description="Specifies the name of the storage account."
}
variable "resource_group_name" {
  description="The name of the resource group in which to create the storage account."
}
variable "location" {
  description="Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
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

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
