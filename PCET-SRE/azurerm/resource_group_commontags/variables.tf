variable "resource_group_name" {
  description="The name of the resource group in which to create the storage account."
}

variable "location" {
  description="Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
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
