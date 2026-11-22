variable "num_agents" {
  description = "Number of agent virtual machines to create."
  type        = number
}

variable "resource_group_name" {
  description = "Resource group that holds the agent VMs."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "subnet_id" {
  description = "Subnet the agent VMs attach to."
  type        = string
}

variable "nsg_name" {
  description = "Name of the network security group created for the agent NICs."
  type        = string
}

variable "vm_name_prefix" {
  description = "Prefix for VM, NIC and disk names."
  type        = string
  default     = "AGENT"
}

variable "agent_vm_size" {
  description = "VM size."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "zones" {
  description = "Availability zones the VMs are spread across in turn. Use [] in regions without zones."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "linux_dialect" {
  description = "Which init script to run: debian (Debian/Ubuntu) or rhel (RHEL and compatibles). Must match linux_image."
  type        = string
  default     = "debian"

  validation {
    condition     = contains(["debian", "rhel"], var.linux_dialect)
    error_message = "linux_dialect must be debian or rhel."
  }
}

variable "linux_image" {
  description = "Marketplace image for the agents. Must match linux_dialect and be a Gen2 image (trusted launch is enabled)."
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

variable "admin_username" {
  description = "Local administrator account. The agents also run as this user."
  type        = string
  default     = "azdoagent"
}

variable "admin_ssh_public_key" {
  description = "SSH public key for the administrator account. Password login is disabled."
  type        = string
}

variable "managed_identity_ids" {
  description = "User-assigned managed identities to attach to the VMs."
  type        = list(string)
  default     = []
}

variable "devops_url" {
  description = "Azure DevOps organisation URL, e.g. https://dev.azure.com/example-org."
  type        = string
}

variable "devops_project_name" {
  description = "Azure DevOps project the agents are registered for."
  type        = string
}

variable "agent_pool_name" {
  description = "Azure DevOps agent pool the agents join."
  type        = string
}

variable "agent_pat_token" {
  description = "Personal access token (Agent Pools: Read & manage) used once, at first boot, to register the agents."
  type        = string
  sensitive   = true
}

variable "agent_version" {
  description = "Azure Pipelines agent version to install."
  type        = string
  default     = "5.283.1"
  nullable    = false
}

variable "agents_per_vm" {
  description = "Number of agent instances to run on each VM."
  type        = number
  default     = 1
}

variable "http_proxy" {
  description = "Optional HTTP proxy URL for the VM and the agents."
  type        = string
  default     = null
}

variable "https_proxy" {
  description = "Optional HTTPS proxy URL for the VM and the agents."
  type        = string
  default     = null
}

variable "no_proxy" {
  description = "Comma-separated destinations that bypass the proxy. The instance metadata address is always added."
  type        = string
  default     = ""
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
