variable "adds_vms" {
  description = "Domain controllers to build, in order. Names are generated (<region><tla><env>001, ...); append to the list, never reorder it."
  type = list(object({
    ip_address = string
    zone       = optional(string)
  }))

  validation {
    condition     = alltrue([for vm in var.adds_vms : can(cidrhost("${vm.ip_address}/32", 0))])
    error_message = "Every adds_vms entry needs a valid IPv4 ip_address."
  }
}

variable "vm_size" {
  description = "VM size for the domain controllers."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  description = "Local administrator account. The password is generated and stored in the hub INFRA Key Vault."
  type        = string
  default     = "azadmin"
}

variable "windows_image" {
  description = "Marketplace image for the domain controllers. Must be a Gen2 image (trusted launch is enabled)."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = optional(string, "latest")
  })
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
  }
}

variable "data_disk_size_gb" {
  description = "Size of the data disk that holds the AD database, logs and SYSVOL."
  type        = number
  default     = 128
}
