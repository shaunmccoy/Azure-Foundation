variable "resource_group_name" {
  description = "Existing resource group that holds the private DNS zones."
  type        = string
}

variable "zones" {
  description = "Private DNS zone names, e.g. privatelink.blob.core.windows.net."
  type        = set(string)
}

variable "virtual_network_links" {
  description = "Virtual networks that resolve these zones: link name => virtual network ID. They may be in other subscriptions of the same tenant."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
