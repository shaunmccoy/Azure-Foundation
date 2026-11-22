variable "resource_group_name" {
  description="The name of the resource group in which to create the KeyVault."
}

variable "location" {
  description="Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "object_id" {
     type        = list(string)
    default     = []
    description = "(Required) The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Changing this forces a new resource to be created."
}

variable "kv_name" {
  default = "kv_name"
  description = "(Required) Specifies the name of the Key Vault. Changing this forces a new resource to be created."
}

variable "tags" {
  description="The tags associated with this application."
}