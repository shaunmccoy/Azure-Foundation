variable "resource_group_name" {
  description="The name of the resource group in which to create the KeyVault."
}

variable "location" {
  description="Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "appinsights_name" { 
}

variable "application_type" { }        

variable "tags" { }