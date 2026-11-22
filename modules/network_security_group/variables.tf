variable "name" {
  description = "Network security group name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that holds the NSG."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "default_rules_enabled" {
  description = "Create the baseline rules: SSH, RDP and ICMP from the virtual network, then deny all other inbound."
  type        = bool
  default     = true
}

variable "rule_name_prefix" {
  description = "Prefix for the baseline rule names."
  type        = string
  default     = "DEFAULT"
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
