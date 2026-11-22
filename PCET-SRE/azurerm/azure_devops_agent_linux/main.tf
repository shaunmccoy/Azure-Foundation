locals {
  # admin name to be assigned to all agents
  admin_username = "azdoagent"
}

resource "azurerm_network_interface" "agents" {
  count               = var.num_agents
  name                = "${var.resource_group_name}-NIC${format("%03d", count.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.resource_group_name}-IP${format("%03d", count.index + 1)}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "agents" {
  count                 = var.num_agents
  name                  = "${var.resource_group_name}-DEVOPSAGENT${format("%03d", count.index + 1)}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.agents[count.index].id]
  size                  = "Standard_D2s_v3"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_username                  = local.admin_username
  admin_password                  = random_password.default_admin_pwd.result
  disable_password_authentication = false
  admin_ssh_key {
    username   = local.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  identity {
    type = "SystemAssigned"
  }
  
  tags = var.tags
}

resource "random_password" "default_admin_pwd" {
  length      = 16
  special     = true
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}

output "password" {
  value = random_password.default_admin_pwd.result
}

output "agents" {
  value = azurerm_linux_virtual_machine.agents
}
