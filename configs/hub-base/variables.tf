variable "zones" {
  description = "Availability zones used by zonal resources in this region. Use [] in regions without zones."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "alert_email_group" {
  description = "Distribution list for platform alerts."
  type        = string
}

variable "defender_plans" {
  description = "Microsoft Defender for Cloud plans switched to the Standard tier on this subscription."
  type        = set(string)
  default     = ["VirtualMachines"]
}

# --- Network -------------------------------------------------------------------------------

variable "vnet_cidr" {
  description = "Address space of the hub virtual network."
  type        = list(string)
}

variable "subnets" {
  description = "Hub subnets keyed by name. GatewaySubnet, AppGateway and PrivateLink are expected."
  type = map(object({
    address_prefixes                  = list(string)
    service_endpoints                 = optional(list(string), [])
    delegation                        = optional(string)
    private_endpoint_network_policies = optional(string, "Enabled")
    default_outbound_access_enabled   = optional(bool)
  }))

  validation {
    condition     = alltrue([for name in ["GatewaySubnet", "PrivateLink"] : contains(keys(var.subnets), name)])
    error_message = "subnets must include GatewaySubnet and PrivateLink."
  }
}

variable "subnets_with_udrs" {
  description = "Subnets that get the default route table (default route to the gateway)."
  type        = set(string)
  default     = []
}

variable "dns_servers" {
  description = "DNS servers for the hub virtual network. Empty uses Azure-provided DNS."
  type        = list(string)
  default     = []
}

variable "internet_route_cidrs" {
  description = "Destinations every route table lets straight out to the Internet (e.g. OS update endpoints)."
  type        = list(string)
  default     = []
}

variable "devops_cidrs" {
  description = "Extra Internet destinations for the DevOps agent subnet (Azure DevOps service ranges)."
  type        = list(string)
  default     = []
}

variable "black_hole_route_cidrs" {
  description = "Address ranges of other environments, dropped so environments cannot reach each other."
  type        = list(string)
  default     = []
}

variable "network_watcher" {
  description = "Existing Network Watcher for this region. Null creates one. Azure allows one per region per subscription."
  type = object({
    name                = string
    resource_group_name = string
  })
  default = null
}

# --- Gateways ------------------------------------------------------------------------------

variable "expressroute_gateway_sku" {
  description = "ExpressRoute gateway SKU."
  type        = string
  default     = "ErGw1AZ"
}

variable "express_route_circuit_id" {
  description = "ExpressRoute circuit serving this region."
  type        = string
  default     = null
}

variable "express_route_authorization_key" {
  description = "Authorization key for the regional circuit. Supply with TF_VAR_express_route_authorization_key."
  type        = string
  default     = null
  sensitive   = true
}

variable "express_route_secondary_circuit_id" {
  description = "Circuit of the paired region, connected as the fallback path."
  type        = string
  default     = null
}

variable "express_route_secondary_authorization_key" {
  description = "Authorization key for the paired region's circuit. Supply with TF_VAR_express_route_secondary_authorization_key."
  type        = string
  default     = null
  sensitive   = true
}

variable "vpn" {
  description = "Optional site-to-site VPN gateway, e.g. as ExpressRoute backup. Null creates none."
  type = object({
    sku                    = optional(string, "VpnGw2AZ")
    active_active          = optional(bool, true)
    onprem_gateway_address = string
    onprem_address_space   = list(string)
  })
  default = null
}

variable "vpn_shared_key" {
  description = "IPsec pre-shared key for the VPN connection. Supply with TF_VAR_vpn_shared_key."
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.vpn == null || try(length(var.vpn_shared_key) >= 32, false)
    error_message = "vpn_shared_key (32+ characters) is required when vpn is set."
  }
}

# --- Private DNS ---------------------------------------------------------------------------

variable "private_dns_zones" {
  description = "Private DNS zones this hub hosts. Set it on exactly one hub (normally production); leave empty elsewhere."
  type        = set(string)
  default     = []

  validation {
    condition = length(var.private_dns_zones) == 0 || alltrue([
      for zone in ["privatelink.vaultcore.azure.net", "privatelink.blob.core.windows.net", "privatelink.azurecr.io"] :
      contains(var.private_dns_zones, zone)
    ])
    error_message = "A hub that hosts private DNS must include the vaultcore, blob and azurecr privatelink zones."
  }
}

variable "private_dns_linked_vnet_ids" {
  description = "Other hub virtual networks linked to the zones hosted here: link name => virtual network ID."
  type        = map(string)
  default     = {}
}

variable "private_dns_subscription_id" {
  description = "Subscription of the hub that hosts the central private DNS zones."
  type        = string
}

variable "private_dns_resource_group_name" {
  description = "Resource group of the central private DNS zones."
  type        = string
}

# --- Container registry --------------------------------------------------------------------

variable "acr_sku" {
  description = "Container registry SKU. Premium is needed for private endpoints, zones and geo-replication."
  type        = string
  default     = "Premium"
}

variable "acr_georeplication_locations" {
  description = "Regions the registry replicates to, so image pulls survive a regional outage."
  type        = set(string)
  default     = []
}
