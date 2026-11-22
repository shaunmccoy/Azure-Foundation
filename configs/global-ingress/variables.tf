variable "dns_relative_name" {
  description = "Globally unique label; the profile answers on <label>.trafficmanager.net. CNAME the public API host name to it."
  type        = string
}

variable "routing_method" {
  description = "Priority: active/passive, traffic moves only on failure. Performance: active/active, each client gets the closest healthy region."
  type        = string
  default     = "Priority"

  validation {
    condition     = contains(["Priority", "Performance", "Weighted"], var.routing_method)
    error_message = "routing_method must be Priority, Performance or Weighted."
  }
}

variable "endpoints" {
  description = "Regional Application Gateway public IPs (output public_ip_id of configs/hub-appgateway), keyed by a short name. Priorities must be unique."
  type = map(object({
    public_ip_id = string
    priority     = number
    weight       = optional(number, 100)
    enabled      = optional(bool, true)
  }))

  validation {
    condition     = length(var.endpoints) >= 2
    error_message = "A global ingress needs at least two regional endpoints."
  }

  validation {
    condition     = length(distinct([for e in values(var.endpoints) : e.priority])) == length(var.endpoints)
    error_message = "Endpoint priorities must be unique."
  }
}

variable "health_probe" {
  description = "How Traffic Manager checks each region, through the Application Gateway to the API Management health endpoint."
  type = object({
    host_header         = string
    path                = optional(string, "/status-0123456789abcdef")
    interval_in_seconds = optional(number, 10)
    timeout_in_seconds  = optional(number, 5)
    tolerated_failures  = optional(number, 2)
  })
}

variable "dns_ttl" {
  description = "TTL of the answers in seconds. Lower fails over faster at the cost of more DNS queries."
  type        = number
  default     = 30
}

variable "alert_action_group_id" {
  description = "Action group notified when a regional endpoint goes unhealthy. Null creates no alert."
  type        = string
  default     = null
}
