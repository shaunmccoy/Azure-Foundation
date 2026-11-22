variable "resource_group_name" {
  description="The name of the resource group in which to create the KeyVault."
}

variable "location" {
  description="Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "appsvc_name" { }

variable "ase_paln_id" { }        

variable "tags" { }

variable "app_settings" {
    description = "A key-value pair of App Settings"
    type        = map(string)
    default     = {}
}