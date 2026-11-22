variable "name" {
  description = "ExpressRoute virtual network gateway name."
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

variable "gateway_subnet_id" {
  description = "ID of the GatewaySubnet in the hub virtual network."
  type        = string
}

variable "public_ip_name" {
  description = "Name of the gateway's public IP."
  type        = string
}

variable "sku" {
  description = "Gateway SKU. The non-zonal Standard/HighPerformance/UltraPerformance SKUs are legacy; use an AZ SKU."
  type        = string
  default     = "ErGw1AZ"

  validation {
    condition     = contains(["ErGw1AZ", "ErGw2AZ", "ErGw3AZ", "ErGwScale"], var.sku)
    error_message = "sku must be ErGw1AZ, ErGw2AZ, ErGw3AZ or ErGwScale."
  }
}

variable "zones" {
  description = "Availability zones for the public IP. Use [] in regions without zones."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "primary_circuit_id" {
  description = "ExpressRoute circuit this gateway connects to. Null creates the gateway without a connection."
  type        = string
  default     = null
}

variable "primary_authorization_key" {
  description = "Authorization key for the primary circuit, when it lives in another subscription."
  type        = string
  default     = null
  sensitive   = true
}

variable "secondary_circuit_id" {
  description = "Circuit in the paired region, connected for cross-region resilience."
  type        = string
  default     = null
}

variable "secondary_authorization_key" {
  description = "Authorization key for the secondary circuit."
  type        = string
  default     = null
  sensitive   = true
}

variable "secondary_routing_weight" {
  description = "Routing weight of the secondary connection. Lower than the primary (10) so the local circuit is preferred."
  type        = number
  default     = 5
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
