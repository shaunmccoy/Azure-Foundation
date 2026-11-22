variable "name" {
  description = "Key Vault name (3-24 characters, globally unique)."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9-]{1,22}[A-Za-z0-9]$", var.name))
    error_message = "name must be 3-24 characters: letters, digits and hyphens, starting with a letter."
  }
}

variable "resource_group_name" {
  description = "Resource group that holds the vault."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID."
  type        = string
}

variable "sku_name" {
  description = "standard or premium (HSM-backed keys)."
  type        = string
  default     = "standard"
}

variable "enabled_for_disk_encryption" {
  description = "Allow Azure Disk Encryption to retrieve secrets and unwrap keys."
  type        = bool
  default     = false
}

variable "enabled_for_deployment" {
  description = "Allow virtual machines to retrieve certificates stored as secrets."
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "Days a deleted vault or object stays recoverable (7-90)."
  type        = number
  default     = 90
}

variable "role_assignments" {
  description = "Azure RBAC grants on the vault: any static key => { principal_id, role_definition_name }."
  type = map(object({
    principal_id         = string
    role_definition_name = string
  }))
  default = {}
}

variable "private_endpoint_subnet_id" {
  description = "Subnet for the vault's private endpoint."
  type        = string
}

variable "private_endpoint_resource_group_name" {
  description = "Resource group for the private endpoint. Defaults to the vault's resource group."
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "IDs of the privatelink.vaultcore.azure.net zone(s) the endpoint registers in. Empty leaves DNS to you."
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace that receives diagnostics."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
