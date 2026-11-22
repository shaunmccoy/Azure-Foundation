locals {
  admin_username = "ansible"
}

resource "random_string" "name" {
  length  = 16
  number  = false
  special = false
}

resource "azurerm_resource_group" "ansible_provisioner" {
  name     = random_string.name.result
  location = "centralus"
}


###############################################################################
# Currently, there is no dedicated test environment at NT that can be accessed
# via private Azure DevOps Agents. To automatically test this use case you
# would need to deploy a VM to a subnet that is connected/peered to the agent
# that this job is run on. Otherwise you must run this example in a 
# subscription that does not have Public IP Deny Policy.
###############################################################################

resource "azurerm_virtual_network" "ansible_provisioner" {
  name                = random_string.name.result
  location            = azurerm_resource_group.ansible_provisioner.location
  resource_group_name = azurerm_resource_group.ansible_provisioner.name
  address_space       = ["192.168.13.0/24"]
}

resource "azurerm_subnet" "ansible_provisioner" {
  name                 = random_string.name.result
  resource_group_name  = azurerm_resource_group.ansible_provisioner.name
  virtual_network_name = azurerm_virtual_network.ansible_provisioner.name
  address_prefix       = "192.168.13.0/24"
}

resource "azurerm_public_ip" "ansible_provisioner" {
  name                = random_string.name.result
  location            = azurerm_resource_group.ansible_provisioner.location
  resource_group_name = azurerm_resource_group.ansible_provisioner.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "ansible_provisioner" {
  name                = random_string.name.result
  location            = azurerm_resource_group.ansible_provisioner.location
  resource_group_name = azurerm_resource_group.ansible_provisioner.name

  ip_configuration {
    name                          = random_string.name.result
    subnet_id                     = azurerm_subnet.ansible_provisioner.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ansible_provisioner.id
  }
}

resource "azurerm_virtual_machine" "ansible_provisioner" {
  name                  = random_string.name.result
  location              = azurerm_resource_group.ansible_provisioner.location
  resource_group_name   = azurerm_resource_group.ansible_provisioner.name
  vm_size               = "Standard_DS2"
  network_interface_ids = [azurerm_network_interface.ansible_provisioner.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = random_string.name.result
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = random_string.name.result
    admin_username = local.admin_username
    admin_password = random_password.default_admin_pwd.result
  }

  os_profile_linux_config {
    disable_password_authentication = true
  }
}

module "ansible_provisioner" {
  source           = "../../"
  virtual_machine  = azurerm_virtual_machine.ansible_provisioner
  host             = azurerm_public_ip.ansible_provisioner.ip_address
  user             = local.admin_username
  ansible_playbook = "main.yml"
}

resource "random_password" "default_admin_pwd" {
  length      = 16
  special     = true
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}