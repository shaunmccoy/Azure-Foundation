variable "name" {
  description = "VPN virtual network gateway name."
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
  description = "Name of the gateway's public IP. A second one, suffixed -2, is created when active_active is true."
  type        = string
}

variable "sku" {
  description = "Gateway SKU. Basic and the non-AZ VpnGw1-5 SKUs are legacy."
  type        = string
  default     = "VpnGw2AZ"

  validation {
    condition     = can(regex("^VpnGw[1-5]AZ$", var.sku))
    error_message = "sku must be one of VpnGw1AZ through VpnGw5AZ."
  }
}

variable "zones" {
  description = "Availability zones for the public IPs. Use [] in regions without zones."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "active_active" {
  description = "Run both gateway instances active, each with its own public IP and tunnel."
  type        = bool
  default     = true
}

variable "bgp_asn" {
  description = "Azure-side BGP ASN. Null disables BGP (static routing from onprem_address_space)."
  type        = number
  default     = null
}

variable "local_network_gateway_name" {
  description = "Name of the local network gateway that represents the on-premises VPN device."
  type        = string
}

variable "onprem_gateway_address" {
  description = "Public IP of the on-premises VPN device."
  type        = string
}

variable "onprem_address_space" {
  description = "On-premises CIDRs reachable through the tunnel."
  type        = list(string)
}

variable "onprem_bgp" {
  description = "On-premises BGP peer. Required when bgp_asn is set."
  type = object({
    asn             = number
    peering_address = string
  })
  default = null
}

variable "shared_key" {
  description = "IPsec pre-shared key. Supply it from Key Vault or a pipeline secret; never commit it."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.shared_key) >= 32
    error_message = "shared_key must be at least 32 characters."
  }
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
