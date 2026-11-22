module "ansible_provisioner" {
  source               = "../../../../provisioners/ansible"
  private_ip_addresses = ["10.102.114.7","10.102.114.6"]
  ansible_playbook     = "../../vm_configuration.yml"
}
