variable "name" {
  description = "Compute gallery name (letters, digits, dots and underscores only)."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that holds the gallery."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "publisher" {
  description = "Publisher recorded on every image definition, usually the organisation name."
  type        = string
  default     = "Organisation"
}

variable "image_definitions" {
  description = "Image definitions keyed by name. Offer defaults to <publisher>-GoldenImage."
  type = map(object({
    os_type = string
    sku     = string
    offer   = optional(string)
  }))
  default = {
    "GoldenImage-Ubuntu2404"  = { os_type = "Linux", sku = "Ubuntu-24.04-LTS" }
    "GoldenImage-RedHat9"     = { os_type = "Linux", sku = "RedHat-9.x" }
    "GoldenImage-Windows2022" = { os_type = "Windows", sku = "Windows-2022" }
    "DevOps-Agent-Ubuntu"     = { os_type = "Linux", sku = "DevOps-Agent-Ubuntu-24.04", offer = "DevOps-Agent" }
  }
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
