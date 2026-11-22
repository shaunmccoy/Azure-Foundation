variable "name" {
  description = "Storage account name (3-24 lowercase letters and digits, globally unique)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "name must be 3-24 lowercase letters and digits."
  }
}

variable "resource_group_name" {
  description = "Resource group that holds the storage account."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "account_tier" {
  description = "Standard or Premium."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "LRS, ZRS, GRS, RAGRS, GZRS or RAGZRS."
  type        = string
  default     = "ZRS"
}

variable "shared_access_key_enabled" {
  description = "Allow account-key and SAS authentication. Leave false; use Entra ID roles."
  type        = bool
  default     = false
}

variable "allow_azure_services" {
  description = "Let trusted Azure services through the firewall (needed for flow logs and diagnostics)."
  type        = bool
  default     = false
}

variable "virtual_network_subnet_ids" {
  description = "Subnets allowed through the firewall by service endpoint."
  type        = list(string)
  default     = []
}

variable "blob_delete_retention_days" {
  description = "Soft-delete retention for blobs and containers."
  type        = number
  default     = 30
}

variable "blob_versioning_enabled" {
  description = "Keep previous blob versions. Turn on for Terraform state."
  type        = bool
  default     = false
}

variable "static_website" {
  description = "Static website hosting. Null disables it."
  type = object({
    index_document     = string
    error_404_document = optional(string)
  })
  default = null
}

variable "private_endpoints" {
  description = "Private endpoints keyed by sub-resource (blob, web, file, queue, table, dfs)."
  type = map(object({
    subnet_id            = string
    private_dns_zone_ids = optional(list(string), [])
  }))
  default = {}
}

variable "private_endpoint_resource_group_name" {
  description = "Resource group for the private endpoints. Defaults to the account's resource group."
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace that receives blob diagnostics."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
