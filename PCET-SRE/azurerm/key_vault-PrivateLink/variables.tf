variable "resource_group_name" {
  description="The name of the resource group in which to create the KeyVault."
}

variable "location" {
  description="Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "vnet_name" {
  description="The name of the virtual network for this KeyVault account will allow access."
}

variable "vnet_resource_group_name" {
 description="The name of the virtual network resourceGroup"
}
  
# variable "tenant_id" {
#  // default = "22222222-2222-2222-2222-222222222222"
#      description = "(Required) The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Changing this forces a new resource to be created."
# }

 variable "object_id" {
    default = "10000000-0000-0000-0000-000000000009"
    description = "(Required) The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Changing this forces a new resource to be created."
 }

variable "kv_name" {
  default = "kv_name"
  description = "(Required) Specifies the name of the Key Vault. Changing this forces a new resource to be created."
}

variable "subnet_name" {
 // default = "privatelink"
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
