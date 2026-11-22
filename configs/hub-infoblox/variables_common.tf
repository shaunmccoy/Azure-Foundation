# Identical in every config under configs/. Change it everywhere or nowhere.

variable "org_code" {
  description = "Short lowercase organisation code. Used as the tag namespace (<org_code>:environment) and as the prefix of globally unique names such as storage accounts."
  type        = string
  default     = "org"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{1,4}$", var.org_code))
    error_message = "org_code must be 2-5 lowercase alphanumeric characters, starting with a letter."
  }
}

variable "subscription_id" {
  description = "Subscription this config deploys into."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "subscription_id must be a GUID."
  }
}

variable "hub_subscription_id" {
  description = "Subscription of the hub for this region and environment."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", var.hub_subscription_id))
    error_message = "hub_subscription_id must be a GUID."
  }
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", var.tenant_id))
    error_message = "tenant_id must be a GUID."
  }
}

variable "location" {
  description = "Azure region name, e.g. centralus. Must be a key of loc_code."
  type        = string

  validation {
    condition     = contains(keys(var.loc_code), var.location)
    error_message = "location must be one of the keys in loc_code."
  }
}

variable "env" {
  description = "Environment name. Must be a key of env_code."
  type        = string

  validation {
    condition     = contains(keys(var.env_code), var.env)
    error_message = "env must be one of the keys in env_code."
  }
}

variable "tla" {
  description = "Three-letter acronym of the application or platform component."
  type        = string
}

variable "business_unit" {
  description = "Business unit code. Appears in resource names and tags."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9]{2,6}$", var.business_unit))
    error_message = "business_unit must be 2-6 alphanumeric characters."
  }
}

variable "cost_center" {
  description = "Cost center for the costCenter tag."
  type        = string
}

variable "loc_code" {
  description = "Azure region name to the short code used in resource names."
  type        = map(string)
  default = {
    australiacentral   = "AUC"
    australiaeast      = "AUE"
    australiasoutheast = "AUS"
    brazilsouth        = "BRS"
    canadacentral      = "CAC"
    canadaeast         = "CAE"
    centralindia       = "INC"
    centralus          = "CUS"
    eastasia           = "AEA"
    eastus             = "EUS"
    eastus2            = "EU2"
    francecentral      = "FRC"
    germanywestcentral = "GWC"
    japaneast          = "JPE"
    japanwest          = "JPW"
    koreacentral       = "KRC"
    northcentralus     = "NCU"
    northeurope        = "EUN"
    southcentralus     = "SCU"
    southeastasia      = "ASE"
    southindia         = "INS"
    swedencentral      = "SWC"
    uksouth            = "UKS"
    ukwest             = "UKW"
    westcentralus      = "WCU"
    westeurope         = "EUW"
    westus             = "WUS"
    westus2            = "WU2"
    westus3            = "WU3"
  }
}

variable "env_code" {
  description = "Environment name to the one-letter code used in resource names."
  type        = map(string)
  default = {
    PROD    = "P"
    PRODDR  = "R"
    UAT     = "U"
    DEV     = "D"
    LAB     = "X"
    SANDBOX = "Z"
  }
}
