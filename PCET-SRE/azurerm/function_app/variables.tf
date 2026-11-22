variable "resource_group_name" {
  description="The name of the resource group in which to create the KeyVault."
}

variable "location" {
  description="Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "funcapp_name" { }
variable "ase_paln_id" { }

variable "storage_account_name" { }

variable "storgae_account_access_key" { }

variable "app_settings" {
    description = "A key-value pair of App Settings"
    type        = map(string)
    default     = {}
}

variable "tags" {
  description="The tags associated with this application."
}