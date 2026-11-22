variable "name" {
  description = "Virtual network name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that holds the virtual network."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "address_space" {
  description = "Address space (CIDR list) of the virtual network."
  type        = list(string)
}

variable "dns_servers" {
  description = "Custom DNS servers. Leave empty to use Azure-provided DNS."
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = <<-EOT
    Subnets keyed by name. `delegation` is the service name, e.g. "Microsoft.Web/serverFarms".
    Leave `default_outbound_access_enabled` null to accept the platform default; set false for
    private subnets that egress through a firewall or NAT gateway.
  EOT
  type = map(object({
    address_prefixes                  = list(string)
    service_endpoints                 = optional(list(string), [])
    delegation                        = optional(string)
    delegation_actions                = optional(list(string), ["Microsoft.Network/virtualNetworks/subnets/action"])
    private_endpoint_network_policies = optional(string, "Enabled")
    default_outbound_access_enabled   = optional(bool)
  }))
}

variable "ddos_protection_plan_id" {
  description = "Optional DDoS Network Protection plan to attach."
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
