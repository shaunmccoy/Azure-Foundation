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
## Cognitive Service creation variables
variable "cognitive_service_name"{
  description = "name of cosmos database"
}
variable "kind"{
  description = "name of cosmos database"
}
variable "sku_name"{
  description = "name of cosmos database"
}