variable "name" {
  description = "Scale set name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that holds the scale set."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "subnet_id" {
  description = "Subnet the instances attach to."
  type        = string
}

variable "sku" {
  description = "VM size."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "instances" {
  description = "Initial instance count. Azure DevOps scale-set agent pools manage capacity themselves, so 0 is normal."
  type        = number
  default     = 0
}

variable "zones" {
  description = "Availability zones to spread instances across."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "source_image_id" {
  description = "Compute gallery image (or image version) ID to boot from."
  type        = string
}

variable "plan" {
  description = "Marketplace plan, when the image was built from a marketplace offer."
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  default = null
}

variable "admin_username" {
  description = "Local administrator account."
  type        = string
  default     = "azdoagent"
}

variable "ssh_public_key" {
  description = "SSH public key for the administrator account. Password login is disabled."
  type        = string
}

variable "custom_data" {
  description = "Base64-encoded cloud-init payload."
  type        = string
  default     = null
  sensitive   = true
}

variable "identity_ids" {
  description = "User-assigned managed identities to attach."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
