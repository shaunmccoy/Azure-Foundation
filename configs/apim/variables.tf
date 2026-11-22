variable "publisher_name" {
  description = "Publisher name shown in the developer portal and notification emails."
  type        = string
}

variable "publisher_email" {
  description = "Address that receives API Management service notifications."
  type        = string
}

variable "sku_tier" {
  description = "Premium for production; Developer for non-production."
  type        = string
  default     = "Premium"
}

variable "capacity" {
  description = "Scale units in the primary region. With zones, a multiple of the zone count."
  type        = number
  default     = 3

  validation {
    condition     = length(var.zones) == 0 || var.capacity % length(var.zones) == 0
    error_message = "capacity must be a multiple of the number of zones, so units spread evenly."
  }
}

variable "zones" {
  description = "Availability zones in the primary region (Premium only). Empty lets Azure place units across zones automatically."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "virtual_network_type" {
  description = "Internal (recommended, fronted by Application Gateway) or External."
  type        = string
  default     = "Internal"
}

variable "apim_subnet_id" {
  description = "API Management subnet in the primary region (APIManagement subnet of the API spoke)."
  type        = string
}

variable "additional_regions" {
  description = <<-EOT
    Extra gateway regions keyed by Azure region name. Each subnet must be in the same
    subscription as the service, so deploy the other region's API spoke into this subscription.
  EOT
  type = map(object({
    subnet_id        = string
    capacity         = optional(number, 3)
    zones            = optional(list(string), ["1", "2", "3"])
    gateway_disabled = optional(bool, false)
  }))
  default = {}

  validation {
    condition     = alltrue([for location in keys(var.additional_regions) : contains(keys(var.loc_code), location)])
    error_message = "additional_regions keys must be region names present in loc_code."
  }

  validation {
    condition     = length(var.additional_regions) == 0 || var.sku_tier == "Premium"
    error_message = "additional_regions needs the Premium tier."
  }
}

variable "primary_gateway_disabled" {
  description = "Take the primary region's gateway out of rotation. External mode only; in Internal mode disable the region's endpoint in configs/global-ingress instead."
  type        = bool
  default     = false
}

variable "client_address_prefix" {
  description = "Source allowed to call the gateway on 443. Narrow to the Application Gateway subnets where possible."
  type        = string
  default     = "VirtualNetwork"
}

variable "key_vault_ids" {
  description = "Key Vaults holding the service's certificates and secrets: any static key => vault ID."
  type        = map(string)
  default     = {}
}

variable "gateway_custom_domains" {
  description = "Custom gateway host names with versionless Key Vault certificate secret IDs."
  type = list(object({
    host_name                    = string
    key_vault_certificate_id     = string
    default_ssl_binding          = optional(bool, false)
    negotiate_client_certificate = optional(bool, false)
  }))
  default = []
}

variable "developer_portal_custom_domain" {
  description = "Custom developer portal host name."
  type = object({
    host_name                = string
    key_vault_certificate_id = string
  })
  default = null
}

variable "management_custom_domain" {
  description = "Custom management endpoint host name."
  type = object({
    host_name                = string
    key_vault_certificate_id = string
  })
  default = null
}

variable "named_values" {
  description = "Secret named values from Key Vault: name => versionless secret ID."
  type        = map(string)
  default     = {}
}

variable "application_insights_sampling_percentage" {
  description = "Share of requests traced to Application Insights. Errors are always logged."
  type        = number
  default     = 20
}

variable "alert_action_group_id" {
  description = "Action group notified by the API Management alerts. Null creates no alerts."
  type        = string
  default     = null
}

variable "delete_lock_enabled" {
  description = "Protect the service with a CanNotDelete lock."
  type        = bool
  default     = true
}

variable "private_dns_records" {
  description = <<-EOT
    Creates one A record per region, <record_prefix>-<region code>, pointing at that region's
    private gateway IP, e.g. api-cus.internal.example.com. Each regional Application Gateway
    uses its region's record as backend. Null creates none.
  EOT
  type = object({
    zone_id       = string
    record_prefix = optional(string, "api")
    ttl           = optional(number, 300)
  })
  default = null
}
