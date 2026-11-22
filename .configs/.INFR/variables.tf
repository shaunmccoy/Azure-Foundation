variable "subscription_id" {
  description = "Subscription ID this configuration deploys into. Leave null to use ARM_SUBSCRIPTION_ID instead."
  type        = string
  default     = null

  validation {
    condition     = var.subscription_id == null || can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "subscription_id must be a GUID."
  }
}

variable "hub_subscription_id" {
  description = "Subscription ID of the hub that hosts the central Log Analytics workspace."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", var.hub_subscription_id))
    error_message = "hub_subscription_id must be a GUID."
  }
}

variable "location" {
  description = "Azure region name, e.g. \"eastus2\". Must be a key in var.loc_code."
  type        = string

  validation {
    condition     = contains(keys(var.loc_code), var.location)
    error_message = "location must be one of the keys in var.loc_code."
  }
}

variable "loc_code" {
  description = "Map of Azure region name to the short code used in resource names."
  type        = map(string)
  default = {
    centralus      = "CUS"
    eastus         = "EUS"
    eastus2        = "EUS2"
    northcentralus = "NCUS"
    southcentralus = "SCUS"
    westus2        = "WUS2"
    westus3        = "WUS3"
  }
}

variable "env" {
  description = "Environment name, e.g. \"dev\". Must be a key in var.env_code."
  type        = string

  validation {
    condition     = contains(keys(var.env_code), var.env)
    error_message = "env must be one of the keys in var.env_code."
  }
}

variable "env_code" {
  description = "Map of environment name to the short code used in resource names."
  type        = map(string)
  default = {
    dev   = "DEV"
    test  = "TST"
    stage = "STG"
    prod  = "PRD"
  }
}

variable "tla" {
  description = "Three-letter application acronym used for tagging."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9]{3}$", var.tla))
    error_message = "tla must be exactly three alphanumeric characters."
  }
}

variable "business_unit" {
  description = "Business unit code used in resource name prefixes and tags."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9]+$", var.business_unit))
    error_message = "business_unit must be alphanumeric (it is embedded in resource names)."
  }
}

variable "cost_center" {
  description = "Cost center applied to the sm:costcenter tag."
  type        = string
}
