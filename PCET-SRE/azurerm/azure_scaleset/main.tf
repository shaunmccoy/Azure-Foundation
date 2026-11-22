resource "random_id" "server" {
  keepers = {
    name            = var.name
    sku             = var.sku_name
    source_image_id = var.image_id
    custom_data     = var.cloud_init
    subnet          = var.subnet_id

  }
  byte_length = 2
}

data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                            = "${upper(var.name)}-SS-${upper(random_id.server.hex)}"
  computer_name_prefix            = "${upper(var.name)}-${upper(random_id.server.hex)}-"
  location                        = data.azurerm_resource_group.rg.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  upgrade_mode                    = var.upgrade_mode
  overprovision                   = var.overprovision
  zones                           = var.zones
  zone_balance                    = var.zone_balance
  instances                       = var.vm_count
  sku                             = random_id.server.keepers.sku
  admin_username                  = var.admin_username
  disable_password_authentication = true
  custom_data                     = random_id.server.keepers.custom_data
  source_image_id                 = random_id.server.keepers.source_image_id

  plan {
    name      = var.plan["name"]
    product   = var.plan["product"]
    publisher = var.plan["publisher"]
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_key
  }

  os_disk {
    caching              = var.os_cache
    storage_account_type = var.managed_disk_type
    diff_disk_settings {
      option = var.diff_disk
    }
    disk_size_gb              = var.os_disk_gb
    write_accelerator_enabled = var.write_accelerator_enabled
  }


  network_interface {
    name    = "${upper(var.name)}-${upper(random_id.server.hex)}-SS-NP"
    primary = true

    ip_configuration {
      name      = "${upper(var.name)}-${upper(random_id.server.hex)}-SS-IPC"
      primary   = true
      subnet_id = random_id.server.keepers.subnet

      load_balancer_backend_address_pool_ids = var.lb_backend_pool_ids
    }
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_type == "SystemAssigned" ? null : var.identity_ids
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}


