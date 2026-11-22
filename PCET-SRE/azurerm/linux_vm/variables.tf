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
}

variable "admin_password"{}

variable "vm_name" {
  description="VM name"
}

variable "linux_custom_image_name" {
  default="NothernTrust-MasterImage-Ubuntu"
}

variable "linux_custom_image_gallery_name" {
  default="exampleimagegallery"
}

variable "linux_custom_image_gallery_rg_name" {
  default="example-imagegallery-rg"
}