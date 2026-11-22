# Ansible Provisioner

This module will apply an Ansible Playbook targeting a host that is passed to it.

## Variables

```hcl
variable "virtual_machine" {
    description = "The Virtual Machine resource to depend on. This will prevent the provisioner from running prematurely."
}

variable "host" {
    description = "The address of the resource to connect to."
}

variable "user" {
    description = "The user that we should use for the connection."
}

variable "private_key_path" {
    description = "The path to an SSH key to use for the connection."
}

variable "ansible_playbook" {
    description = "The path to the Ansible Playbook YAML to apply."
}
```
