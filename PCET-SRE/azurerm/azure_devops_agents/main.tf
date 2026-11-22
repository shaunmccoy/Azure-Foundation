resource "azurerm_virtual_machine_scale_set" "azure_devops_agents" {
  name                 = var.name
  location             = var.location
  resource_group_name  = var.resource_group_name
  automatic_os_upgrade = false
  upgrade_policy_mode  = "Manual"

  sku {
    name     = var.sku_name
    tier     = "Standard"
    capacity = var.capacity
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.managed_disk_type
  }

  os_profile {
    computer_name_prefix = var.name
    admin_username       = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = var.key_data
    }
  }

  network_profile {
    name    = var.name
    primary = true

    ip_configuration {
      name      = var.name
      primary   = true
      subnet_id = var.subnet_id
    }
  }

  tags = var.tags
}