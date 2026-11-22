variable "name" {
  description = "Public IP name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that holds the public IP."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "zones" {
  description = "Availability zones. Use [] in regions without zones."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "domain_name_label" {
  description = "Optional DNS label, giving <label>.<region>.cloudapp.azure.com. Needed for Traffic Manager endpoints."
  type        = string
  default     = null
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
