variable "name" {
  description = "Route table name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that holds the route table."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "bgp_route_propagation_enabled" {
  description = "Whether routes learned from the virtual network gateway propagate to this table."
  type        = bool
  default     = true
}

variable "internet_route_cidrs" {
  description = "Destination CIDRs that are allowed straight out to the Internet."
  type        = list(string)
  default     = []
}

variable "black_hole_route_cidrs" {
  description = "Destination CIDRs that are dropped (next hop None), e.g. other environments."
  type        = list(string)
  default     = []
}

variable "default_next_hop_type" {
  description = "Next hop for 0.0.0.0/0."
  type        = string
  default     = "VirtualNetworkGateway"

  validation {
    condition     = contains(["VirtualNetworkGateway", "VnetLocal", "Internet", "VirtualAppliance", "None"], var.default_next_hop_type)
    error_message = "default_next_hop_type must be VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance or None."
  }
}

variable "default_next_hop_ip_address" {
  description = "Firewall/NVA IP. Required when default_next_hop_type is VirtualAppliance."
  type        = string
  default     = null

  validation {
    condition     = (var.default_next_hop_type == "VirtualAppliance") == (var.default_next_hop_ip_address != null)
    error_message = "Set default_next_hop_ip_address only (and always) when default_next_hop_type is VirtualAppliance."
  }
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
