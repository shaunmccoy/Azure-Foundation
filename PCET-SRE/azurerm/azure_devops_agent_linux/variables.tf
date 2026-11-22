variable "vnet_name" {
  
}

variable "num_agents" {

}
variable "subnet_id" {
  
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual machine scale set. Changing this forces a new resource to be created."
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     = {}
}

variable "location" {
  description="Azure region (centralus, eastus2)"
  default="northcentralus"
}