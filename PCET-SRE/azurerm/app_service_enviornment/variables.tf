variable "ase_name" {
  description   = "Specifies the name of the App Service enviornment. Changing this forces a new resource to be created."
}

variable "front_end_scale_factor" {
  default       = 10
  description   = "frontend scale value, could be 10, 15, 20, default set is 10"    
}

variable "pricing_tier" {
  default       = "I1"
  description   = "pricing tier for servers in ASE, it could be I1, I2 etc" 
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     = {}
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
variable "resource_group_name" { }