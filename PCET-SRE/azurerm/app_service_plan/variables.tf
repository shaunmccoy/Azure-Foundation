variable "ase_plan_name" {
  description   = "Specifies the name of the App Service enviornment. Changing this forces a new resource to be created."
}

variable "plan_tier" {
  default       = "Standard"
  description   = "pricing tier for servers in ASE, it could be I1, I2 etc" 
}

variable "plan_size" {
  default       = "S1"
  description   = "pricing tier for servers in ASE, it could be I1, I2 etc" 
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     = {}
}

variable "resource_group_name" {
}

variable "location" {
}

variable "app_service_environment_id" {}

variable "app_kind" {}

variable "reserved" {}