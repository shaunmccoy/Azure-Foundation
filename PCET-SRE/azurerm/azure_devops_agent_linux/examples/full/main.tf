data "azurerm_subnet" "management" {
  name                 = "Management"
  virtual_network_name = "example-vnet"
  resource_group_name  = "example-net-rg"
}

module "azure_devops_agent_linux" {
  source = "../../"

  tla                 = "AZR"
  cost_center         = "0881"
  business_unit       = "INFR"
  vnet_name           = "example-vnet"
  resource_group_name = "example-devops-rg"
  subnet_id           = data.azurerm_subnet.management.id
  num_agents          = 2
}

module "ansible_provisioner" {
  source               = "../../../../provisioners/ansible"
  private_ip_addresses = module.azure_devops_agent_linux.private_ip_addresses
  ansible_playbook     = "../../vm_configuration.yml"
}
