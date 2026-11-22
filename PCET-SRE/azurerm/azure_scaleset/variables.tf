# Required variables
variable "name" {
  type        = string
  description = "Name for the scale set"
}

variable "rg_name" {
  type        = string
  description = "Name of resource group to be added to"
}

variable "image_id" {
  type        = string
  description = "ID of img to use"
}

variable "cloud_init" {
  type        = string
  description = "Init data for VM"
}

variable "subnet_id" {
  type        = string
  description = "ID of subnet to use"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
}

# Provisioning variables
variable "upgrade_mode" {
  type        = string
  description = "Method for updating VMs in scaleset"
  default     = "Manual"
}

variable "overprovision" {
  type        = bool
  description = "Disable overprovisioning, Azure DevOps will manage this"
  default     = false
}

variable "zones" {
  type        = list(string)
  description = "Number of zones to spread out VMs. Options are 1, 2, 3"
  default     = ["1", "2"]
}

variable "zone_balance" {
  type        = bool
  description = "Balance VMs across zones"
  default     = true
}
# Sku variables

variable "sku_name" {
  type        = string
  description = "Size of VMs"
  default     = "Standard_D2s_v3"
}

variable "vm_count" {
  type        = number
  description = "Default vm count for scaleset"
  default     = 2
}

# OS plan source
variable "plan" {
  type    = map(string)
  default = {}
}


# OS Profile
variable "admin_username" {
  type        = string
  description = "Admin username"
  default     = "azdoagent"
}

variable "ssh_key" {
  type        = string
  description = "SSH public key data"
  default     = null
}

variable "identity_type" {
  type        = string
  description = "Whether identity type is either SystemAssigned or UserAssigned"
  default     = "SystemAssigned"
}

variable "identity_ids" {
  type        = list(string)
  description = "List of user managed identity ids to assign"
  default     = []
}

# OS Disk
variable "os_cache" {
  type        = string
  description = "The type of Caching which should be used for this Data Disk. Possible values are None, ReadOnly and ReadWrite"
  default     = "ReadOnly"
}

variable "diff_disk" {
  type    = string
  default = "Local"
}

variable "os_disk_gb" {
  type    = number
  default = 30
}

variable "managed_disk_type" {
  type        = string
  description = "Default disk type"
  default     = "Standard_LRS"
}

variable "write_accelerator_enabled" {
  type        = bool
  description = "Should Write Accelerator be enabled for this Data Disk?"
  default     = false
}

# Network options
variable "lb_backend_pool_ids" {
  type        = list(string)
  description = "Specifies an array of references to backend address pools of load balancers"
  default     = []
}

# Extension options
