variable "name" {
  description = "Specifies the name of the virtual machine scale set resource. Changing this forces a new resource to be created."
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual machine scale set. Changing this forces a new resource to be created."
}

variable "sku_name" {
  description = "Specifies the size of virtual machines in a scale set."
}

variable "capacity" {
  description = "Specifies the number of virtual machines in the scale set."
}

variable "managed_disk_type" {
  description = "Specifies the type of managed disk to create. Value must be either Standard_LRS, StandardSSD_LRS or Premium_LRS. "
}

variable "admin_username" {
  description = "Specifies the administrator account name to use for all the instances of virtual machines in the scale set. "
}

variable "key_data" {
  description = "The Public SSH Key which should be written to the authorized_keys file."
}

variable "subnet_id" {
  description = "Specifies the identifier of the subnet."
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
