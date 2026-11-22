variable "name" {
  description = "API Management service name (globally unique, becomes <name>.azure-api.net)."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9-]{0,48}[A-Za-z0-9]$", var.name))
    error_message = "name must be 2-50 characters: letters, digits and hyphens, starting with a letter."
  }
}

variable "resource_group_name" {
  description = "Resource group that holds the service and its supporting resources."
  type        = string
}

variable "location" {
  description = "Primary (home) region. The management plane and developer portal live only here."
  type        = string
}

variable "publisher_name" {
  description = "Publisher name shown in the developer portal and notification emails."
  type        = string
}

variable "publisher_email" {
  description = "Address that receives service notifications."
  type        = string
}

variable "sku_tier" {
  description = "Premium for production (zones, multi-region, SLA). Developer for non-production only: single instance, no SLA."
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Developer", "Premium"], var.sku_tier)
    error_message = "sku_tier must be Developer or Premium; these are the tiers that support classic VNet injection."
  }
}

variable "capacity" {
  description = "Scale units in the primary region."
  type        = number
  default     = 3

  validation {
    condition     = var.capacity >= 1 && (var.sku_tier != "Developer" || var.capacity == 1)
    error_message = "capacity must be at least 1, and exactly 1 for the Developer tier."
  }
}

variable "zones" {
  description = "Availability zones for the primary region (Premium only). Capacity must divide evenly across them. Empty lets Azure place the units across zones automatically."
  type        = list(string)
  default     = ["1", "2", "3"]

  validation {
    condition     = var.sku_tier != "Premium" || length(var.zones) == 0 || var.capacity % length(var.zones) == 0
    error_message = "capacity must be a multiple of the number of zones, so units spread evenly."
  }
}

variable "virtual_network_type" {
  description = "Internal: gateway reachable only inside the VNet (front it with Application Gateway). External: gateway also has a public endpoint."
  type        = string
  default     = "Internal"

  validation {
    condition     = contains(["Internal", "External"], var.virtual_network_type)
    error_message = "virtual_network_type must be Internal or External."
  }
}

variable "subnet_id" {
  description = "Dedicated API Management subnet in the primary region."
  type        = string
}

variable "additional_locations" {
  description = "Extra gateway regions keyed by Azure region name (e.g. eastus2). Premium only."
  type = map(object({
    subnet_id        = string
    capacity         = optional(number, 3)
    zones            = optional(list(string), ["1", "2", "3"])
    gateway_disabled = optional(bool, false)
  }))
  default = {}

  validation {
    condition     = var.virtual_network_type != "Internal" || alltrue([for l in values(var.additional_locations) : !l.gateway_disabled])
    error_message = "gateway_disabled is not supported in Internal mode. Take a region out of rotation at the load balancer in front (configs/global-ingress) instead."
  }

  validation {
    condition     = length(var.additional_locations) == 0 || var.sku_tier == "Premium"
    error_message = "additional_locations needs the Premium tier."
  }

  validation {
    condition     = alltrue([for location in keys(var.additional_locations) : can(regex("^[a-z0-9]+$", location)) && location != var.location])
    error_message = "additional_locations keys must be lowercase region names without spaces, and differ from location."
  }

  validation {
    condition     = alltrue([for l in values(var.additional_locations) : length(l.zones) == 0 || l.capacity % length(l.zones) == 0])
    error_message = "Each additional location's capacity must be a multiple of its number of zones."
  }
}

variable "primary_gateway_disabled" {
  description = "Take the primary region's gateway out of service (failover drill). External mode with additional_locations only; Azure does not support it in Internal mode."
  type        = bool
  default     = false

  validation {
    condition     = !var.primary_gateway_disabled || length(var.additional_locations) > 0
    error_message = "primary_gateway_disabled needs at least one additional location to carry traffic."
  }

  validation {
    condition     = !var.primary_gateway_disabled || var.virtual_network_type != "Internal"
    error_message = "primary_gateway_disabled is not supported in Internal mode. Take a region out of rotation at the load balancer in front (configs/global-ingress) instead."
  }
}

variable "public_ip_enabled" {
  description = "Create and attach your own Standard public IP in each region. Not needed in Internal mode; in External mode Azure manages one unless you want to own the address."
  type        = bool
  default     = false
}

variable "manage_subnet_nsg" {
  description = "Create and attach a network security group with the rules API Management needs, per region."
  type        = bool
  default     = true
}

variable "client_address_prefix" {
  description = "Source allowed to call the gateway on 443 (Internal mode). Narrow it to the Application Gateway subnet where possible."
  type        = string
  default     = "VirtualNetwork"
}

variable "min_api_version" {
  description = "Oldest management API version the service accepts. Blocks legacy versions that can expose secrets."
  type        = string
  default     = "2021-08-01"
}

variable "key_vault_ids" {
  description = "Key Vaults the service identity may read certificates and secrets from: any static key => vault ID."
  type        = map(string)
  default     = {}
}

variable "gateway_custom_domains" {
  description = "Custom gateway host names with Key Vault certificates. Exactly one should set default_ssl_binding."
  type = list(object({
    host_name                    = string
    key_vault_certificate_id     = string
    default_ssl_binding          = optional(bool, false)
    negotiate_client_certificate = optional(bool, false)
  }))
  default = []
}

variable "developer_portal_custom_domain" {
  description = "Custom developer portal host name with a Key Vault certificate."
  type = object({
    host_name                = string
    key_vault_certificate_id = string
  })
  default = null
}

variable "management_custom_domain" {
  description = "Custom management endpoint host name with a Key Vault certificate."
  type = object({
    host_name                = string
    key_vault_certificate_id = string
  })
  default = null
}

variable "named_values" {
  description = "Secret named values resolved from Key Vault: named value name => versionless secret ID."
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace for diagnostics and the Application Insights component."
  type        = string
}

variable "application_insights_enabled" {
  description = "Create a workspace-based Application Insights component and wire the gateway to it."
  type        = bool
  default     = true
}

variable "application_insights_sampling_percentage" {
  description = "Share of requests traced to Application Insights. Errors are always logged."
  type        = number
  default     = 20

  validation {
    condition     = var.application_insights_sampling_percentage >= 0 && var.application_insights_sampling_percentage <= 100
    error_message = "application_insights_sampling_percentage must be between 0 and 100."
  }
}

variable "alerts" {
  description = "Metric and health alerts. Null creates none."
  type = object({
    action_group_id            = string
    capacity_percent           = optional(number, 75)
    gateway_5xx_per_5_minutes  = optional(number, 25)
    backend_duration_ms        = optional(number, 5000)
    unauthorized_per_5_minutes = optional(number, 200)
  })
  default = null
}

variable "delete_lock_enabled" {
  description = "Put a CanNotDelete lock on the service. A deleted name stays reserved for 48 hours, so accidental deletion is a long outage."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
