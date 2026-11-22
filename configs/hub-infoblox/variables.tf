variable "infoblox_vms" {
  description = "Infoblox appliances to build, in order. Names are generated (<prefix>INFOBLOX01, ...); append to the list, never reorder it."
  type = list(object({
    ip_address = string
    zone       = optional(string)
  }))

  validation {
    condition     = alltrue([for vm in var.infoblox_vms : can(cidrhost("${vm.ip_address}/32", 0))])
    error_message = "Every infoblox_vms entry needs a valid IPv4 ip_address."
  }
}

variable "grid_member_addresses" {
  description = "IP addresses of the existing (on-premises) Infoblox grid members allowed to open grid connections to these appliances."
  type        = list(string)
  default     = []
}

variable "vm_size" {
  description = "VM size for the appliances. Check the Infoblox sizing guide for the chosen NIOS model."
  type        = string
  default     = "Standard_D8s_v5"
}

variable "admin_username" {
  description = "Administrator account Azure requires at provisioning. The password is generated and stored in the hub INFRA Key Vault."
  type        = string
  default     = "azadmin"
}

variable "infoblox_image" {
  description = "Marketplace image and plan of the Infoblox NIOS appliance. No default: pick a currently published offer with `az vm image list --publisher infoblox --all -o table`."
  type = object({
    publisher = optional(string, "infoblox")
    offer     = string
    sku       = string
    version   = optional(string, "latest")
  })
}

variable "accept_marketplace_terms" {
  description = "Accept the marketplace terms for infoblox_image in this subscription. Leave false if they were already accepted (once per subscription)."
  type        = bool
  default     = false
}

variable "trusted_launch_enabled" {
  description = "Enable secure boot and vTPM. Only for Gen2 appliance images that support trusted launch."
  type        = bool
  default     = false
}

variable "data_disk_size_gb" {
  description = "Size of the appliance data disk."
  type        = number
  default     = 128
}
