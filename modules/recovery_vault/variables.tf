variable "name" {
  description = "Recovery Services vault name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that holds the vault."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "storage_mode_type" {
  description = "Backup storage redundancy: GeoRedundant, ZoneRedundant or LocallyRedundant."
  type        = string
  default     = "GeoRedundant"
}

variable "cross_region_restore_enabled" {
  description = "Allow restores in the paired region. Needs GeoRedundant storage."
  type        = bool
  default     = true
}

variable "immutability" {
  description = "Unlocked, Locked (irreversible) or Disabled."
  type        = string
  default     = "Unlocked"
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
