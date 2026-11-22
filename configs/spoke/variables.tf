variable "zones" {
  description = "Availability zones used by zonal resources in this region. Use [] in regions without zones."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "alert_email_group" {
  description = "Distribution list for this spoke's alerts."
  type        = string
}

variable "subscription_baseline_enabled" {
  description = "Manage the subscription-wide settings here: activity log export, CIS alerts and Defender plans. Set false on the second regional spoke when two spokes share one subscription."
  type        = bool
  default     = true
}

variable "defender_plans" {
  description = "Microsoft Defender for Cloud plans switched to the Standard tier on this subscription."
  type        = set(string)
  default     = ["VirtualMachines"]
}

# --- Network -------------------------------------------------------------------------------

variable "vnet_cidr" {
  description = "Address space of the spoke virtual network."
  type        = list(string)
}

variable "subnets" {
  description = "Spoke subnets keyed by name. PrivateLink is required; delegation and service endpoints are optional per subnet."
  type = map(object({
    address_prefixes                  = list(string)
    service_endpoints                 = optional(list(string), [])
    delegation                        = optional(string)
    private_endpoint_network_policies = optional(string, "Enabled")
    default_outbound_access_enabled   = optional(bool)
  }))

  validation {
    condition     = contains(keys(var.subnets), "PrivateLink")
    error_message = "subnets must include PrivateLink."
  }
}

variable "dns_servers" {
  description = "DNS servers for the spoke virtual network, normally the hub DNS appliances. Empty uses Azure-provided DNS."
  type        = list(string)
  default     = []
}

variable "subnets_with_default_udr" {
  description = "Subnets that get the default route table (default route to the hub gateway). Null means every subnet not claimed by additional_route_tables."
  type        = set(string)
  default     = null
}

variable "internet_route_cidrs" {
  description = "Destinations the default route table lets straight out to the Internet."
  type        = list(string)
  default     = []
}

variable "black_hole_route_cidrs" {
  description = "Address ranges of other environments, dropped so environments cannot reach each other."
  type        = list(string)
  default     = []
}

variable "additional_route_tables" {
  description = <<-EOT
    Extra route tables for subnets that must not follow the default route, keyed by a short name
    (the table is named <prefix>-UDR-<NAME>). API Management, Application Gateway and VNet-injected
    Redis need a default route of Internet to reach their control planes.
  EOT
  type = map(object({
    subnets               = set(string)
    default_next_hop_type = optional(string, "Internet")
    internet_route_cidrs  = optional(list(string), [])
  }))
  default = {}

  validation {
    condition = length(flatten([for cfg in values(var.additional_route_tables) : tolist(cfg.subnets)])) == length(distinct(flatten([
      for cfg in values(var.additional_route_tables) : tolist(cfg.subnets)
    ])))
    error_message = "A subnet can be listed in only one additional route table."
  }
}

variable "use_hub_gateway" {
  description = "Route on-premises traffic through the hub's virtual network gateway."
  type        = bool
  default     = true
}

variable "network_watcher" {
  description = "Existing Network Watcher for this region. Null creates one. Azure allows one per region per subscription."
  type = object({
    name                = string
    resource_group_name = string
  })
  default = null
}

variable "redis_subnet_name" {
  description = "Subnet reserved for VNet-injected Azure Cache for Redis; gets the NSG that service requires. Null skips it."
  type        = string
  default     = null
}

# --- Private DNS ---------------------------------------------------------------------------

variable "private_dns_subscription_id" {
  description = "Subscription of the hub that hosts the central private DNS zones."
  type        = string
}

variable "private_dns_resource_group_name" {
  description = "Resource group of the central private DNS zones."
  type        = string
}

# --- Build agents --------------------------------------------------------------------------

variable "agent_scaleset" {
  description = "Optional Azure DevOps scale-set build agents in the DevOpsAgents subnet. Null creates none."
  type = object({
    image_id            = string
    ssh_public_key      = string
    devops_url          = string
    devops_project_name = string
    pool_name           = string
    admin_username      = optional(string, "azdoagent")
    hub_identity_id     = optional(string)
    plan = optional(object({
      name      = string
      product   = string
      publisher = string
    }))
  })
  default = null
}

variable "scaleset_pat_token" {
  description = "Azure DevOps token the scale-set agents register with. Supply with TF_VAR_scaleset_pat_token."
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.agent_scaleset == null || var.scaleset_pat_token != null
    error_message = "scaleset_pat_token is required when agent_scaleset is set."
  }
}
