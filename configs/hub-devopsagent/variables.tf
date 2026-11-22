variable "agent_devops_url" {
  description = "Azure DevOps organisation URL, e.g. https://dev.azure.com/example-org."
  type        = string
}

variable "agent_devops_project_name" {
  description = "Azure DevOps project the agents are registered for."
  type        = string
}

variable "agent_admin_username" {
  description = "Local administrator account on the agents. The agents also run as this user."
  type        = string
  default     = "azdoagent"
}

variable "http_proxy" {
  description = "Optional HTTP proxy URL for the agents."
  type        = string
  default     = null
}

variable "https_proxy" {
  description = "Optional HTTPS proxy URL for the agents."
  type        = string
  default     = null
}

### Static agent VMs ###

variable "number_of_vms" {
  description = "Number of static agent VMs."
  type        = number
  default     = 2
}

variable "agent_pool_name" {
  description = "Azure DevOps agent pool the static agent VMs join."
  type        = string
}

variable "agent_pat_token" {
  description = "Personal access token used once, at first boot, to register the static agents. Supply through TF_VAR_agent_pat_token or a pipeline secret, never a tfvars file."
  type        = string
  sensitive   = true
}

variable "agent_linux_dialect" {
  description = "Init script family for the static agents: debian or rhel. Must match agent_linux_image."
  type        = string
  default     = "debian"
}

variable "agent_linux_image" {
  description = "Marketplace image for the static agents."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = optional(string, "latest")
  })
  default = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
  }
}

variable "agent_version" {
  description = "Azure Pipelines agent version installed on the static agents. Null uses the module default."
  type        = string
  default     = null
}

### Scale-set agents ###

variable "scaleset_enabled" {
  description = "Build the agent scale set. Needs the agent image to exist in the compute gallery."
  type        = bool
  default     = true
}

variable "agent_scale_pool_name" {
  description = "Azure DevOps agent pool the scale-set instances join."
  type        = string
}

variable "scaleset_pat_token" {
  description = "Personal access token the scale-set instances use to register themselves. Supply through TF_VAR_scaleset_pat_token or a pipeline secret, never a tfvars file."
  type        = string
  sensitive   = true
}

variable "plan" {
  description = "Marketplace plan of the agent image, when it was built from a marketplace offer such as a CIS hardened image."
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  default = null
}

variable "img_subscription_id" {
  description = "Subscription that hosts the compute gallery with the agent image."
  type        = string
}

variable "img_resource_group_name" {
  description = "Resource group of the compute gallery."
  type        = string
}

variable "img_gallery_name" {
  description = "Compute gallery name."
  type        = string
}

variable "img_name" {
  description = "Image definition of the agent image. The scale set tracks its latest version."
  type        = string
}
