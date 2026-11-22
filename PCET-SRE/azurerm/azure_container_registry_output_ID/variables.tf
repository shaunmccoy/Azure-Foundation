variable name {
  description = "Specifies the name of the Container Registry. Changing this forces a new resource to be created."
}
variable resource_group_name {
  description = "The name of the resource group in which to create the Container Registry. Changing this forces a new resource to be created."
}
variable location {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}
variable admin_enabled {
  description = "Specifies whether the admin user is enabled."
  default     = false
}
variable sku {
  description = "The SKU name of the the container registry. Possible values are Basic, Standard, and Premium."
  default     = "Premium"
}
variable georeplication_locations {
  description = "A list of Azure locations where the container registry should be geo-replicated."
  type        = list
  default     = null
}
variable tags {
  description = "A mapping of tags to assign to the resource."
  default     = {}
}