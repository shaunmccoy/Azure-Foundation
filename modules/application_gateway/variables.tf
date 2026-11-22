variable "name" {
  description = "Application Gateway name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that holds the gateway."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "subnet_id" {
  description = "Dedicated Application Gateway subnet (/24 recommended for v2)."
  type        = string
}

variable "public_ip_address_id" {
  description = "Standard static public IP for the public frontend."
  type        = string
}

variable "private_ip_address" {
  description = "Optional static private frontend IP inside subnet_id. Listeners select it with frontend = \"private\"."
  type        = string
  default     = null
}

variable "zones" {
  description = "Availability zones. Use [] in regions without zones."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "waf_enabled" {
  description = "Deploy the WAF_v2 SKU with a firewall policy. False deploys Standard_v2."
  type        = bool
  default     = true
}

variable "waf_mode" {
  description = "Prevention blocks matching requests; Detection only logs them."
  type        = string
  default     = "Prevention"

  validation {
    condition     = contains(["Prevention", "Detection"], var.waf_mode)
    error_message = "waf_mode must be Prevention or Detection."
  }
}

variable "min_capacity" {
  description = "Minimum autoscale instances. Keep at 2 or more in production so a zone loss needs no scale-out."
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum autoscale instances."
  type        = number
  default     = 10
}

variable "ssl_policy_name" {
  description = "Predefined TLS policy. AppGwSslPolicy20220101 is TLS 1.2+ with TLS 1.3; the S variant drops CBC suites."
  type        = string
  default     = "AppGwSslPolicy20220101"
}

variable "identity_ids" {
  description = "User-assigned identities that can read the Key Vault certificates (Key Vault Secrets User)."
  type        = list(string)
  default     = []
}

variable "ssl_certificates" {
  description = "Listener certificates: name => versionless Key Vault secret ID."
  type        = map(string)
  default     = {}
}

variable "trusted_root_certificates" {
  description = "Private CA roots for backend TLS: name => versionless Key Vault secret ID."
  type        = map(string)
  default     = {}
}

variable "listeners" {
  description = "HTTP(S) listeners keyed by name."
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

  validation {
    condition     = alltrue([for l in values(var.listeners) : contains(["public", "private"], l.frontend)])
    error_message = "listener frontend must be public or private."
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
  description = "Health probes keyed by name. Leave host null to take it from the backend settings."
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
  description = "Routing rules keyed by name. Set either the backend pair or redirect_to_listener (permanent redirect, e.g. HTTP to HTTPS)."
  type = map(object({
    priority              = number
    listener_name         = string
    backend_pool_name     = optional(string)
    backend_settings_name = optional(string)
    redirect_to_listener  = optional(string)
  }))

  validation {
    condition = alltrue([
      for r in values(var.routing_rules) :
      (r.redirect_to_listener != null) != (r.backend_pool_name != null && r.backend_settings_name != null)
    ])
    error_message = "Each routing rule needs either backend_pool_name and backend_settings_name, or redirect_to_listener."
  }
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace that receives access, performance and firewall logs."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
