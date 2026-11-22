variable "zones" {
  description = "Availability zones. Use [] in regions without zones."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "subnet_name" {
  description = "Hub subnet dedicated to the Application Gateway."
  type        = string
  default     = "AppGateway"
}

variable "waf_mode" {
  description = "Prevention or Detection. Start new sites in Detection, tune, then switch."
  type        = string
  default     = "Prevention"
}

variable "min_capacity" {
  description = "Minimum autoscale instances."
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum autoscale instances."
  type        = number
  default     = 10
}

variable "ssl_certificates" {
  description = "Listener certificates: name => versionless Key Vault secret ID in the hub INFRA vault."
  type        = map(string)
  default     = {}
}

variable "trusted_root_certificates" {
  description = "Private CA roots for backend TLS: name => versionless Key Vault secret ID."
  type        = map(string)
  default     = {}
}

variable "listeners" {
  description = "Listeners keyed by name. See modules/application_gateway."
  type = map(object({
    port                 = number
    protocol             = optional(string, "Https")
    host_names           = optional(list(string), [])
    ssl_certificate_name = optional(string)
    frontend             = optional(string, "public")
  }))

  validation {
    condition     = alltrue([for l in values(var.listeners) : (l.protocol == "Https") == (l.ssl_certificate_name != null)])
    error_message = "Https listeners need ssl_certificate_name; Http listeners must not set it."
  }
}

variable "backend_pools" {
  description = "Backend pools keyed by name."
  type = map(object({
    fqdns        = optional(list(string), [])
    ip_addresses = optional(list(string), [])
  }))
}

variable "backend_settings" {
  description = "Backend HTTP settings keyed by name."
  type = map(object({
    port                                = optional(number, 443)
    protocol                            = optional(string, "Https")
    host_name                           = optional(string)
    pick_host_name_from_backend_address = optional(bool, false)
    request_timeout                     = optional(number, 30)
    cookie_based_affinity               = optional(string, "Disabled")
    probe_name                          = optional(string)
    trusted_root_certificate_names      = optional(list(string), [])
    connection_draining_seconds         = optional(number, 30)
  }))
}

variable "probes" {
  description = "Health probes keyed by name."
  type = map(object({
    protocol            = optional(string, "Https")
    path                = string
    host                = optional(string)
    interval            = optional(number, 30)
    timeout             = optional(number, 30)
    unhealthy_threshold = optional(number, 3)
    status_codes        = optional(list(string), ["200-399"])
  }))
  default = {}
}

variable "routing_rules" {
  description = "Routing rules keyed by name."
  type = map(object({
    priority              = number
    listener_name         = string
    backend_pool_name     = optional(string)
    backend_settings_name = optional(string)
    redirect_to_listener  = optional(string)
  }))
}
