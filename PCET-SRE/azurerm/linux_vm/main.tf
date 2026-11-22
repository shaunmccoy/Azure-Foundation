locals {
  # admin name to be assigned to all agents
  admin_username = "ubuntuadmin"
}

resource "azurerm_network_interface" "agents" {
  count               = var.num_agents
  name                = "${var.vm_name}-NIC${format("%03d", count.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.resource_group_name}-IP${format("%03d", count.index + 1)}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

data "azurerm_shared_image" "linux_image" {
  name                = var.linux_custom_image_name					# e.g. "pipeline-agent-ubuntu"
  gallery_name        = var.linux_custom_image_gallery_name			# "MyImageGalleryName"
  resource_group_name = var.linux_custom_image_gallery_rg_name		# "ImageGalleryResourceGroupName"

  provider = azurerm.image
     #mention alias to pull image into different subscription
}

resource "azurerm_linux_virtual_machine" "agents" {
  count                 = var.num_agents
  name                  = "${var.vm_name}-${format("%03d", count.index + 1)}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.agents[count.index].id]
  size                  = "Standard_D2s_v3"
  source_image_id       = data.azurerm_shared_image.linux_image.id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name = "cis-ubuntu1804-l1"
    product = "cis-ubuntu-linux-1804-l1"
    publisher = "center-for-internet-security-inc"
  }

  admin_username                  = local.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  admin_ssh_key {
    username   = local.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }
  
  tags = var.tags
}

output "agents" {
  value = azurerm_linux_virtual_machine.agents
}
