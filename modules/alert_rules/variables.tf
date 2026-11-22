variable "resource_group_name" {
  description = "Resource group that holds the action group and alerts."
  type        = string
}

variable "subscription_id" {
  description = "Subscription whose activity log is watched."
  type        = string
}

variable "action_group_name" {
  description = "Action group name."
  type        = string
  default     = "Default Action Group"
}

variable "email_address" {
  description = "Distribution list that receives the alerts."
  type        = string
}

variable "policy_alert_prefix" {
  description = "Prefix for the organisation's own (non-CIS) policy alert."
  type        = string
  default     = "ORG"
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
