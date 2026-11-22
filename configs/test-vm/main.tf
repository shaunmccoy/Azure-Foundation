# Throw-away Linux and Windows VMs for testing routing, DNS, proxy and firewall
# rules from a chosen subnet. Destroy them when the test is done.

data "azurerm_key_vault" "infra" {
  name                = local.hub_names.infra_keyvault
  resource_group_name = local.hub_names.keyvault_resource_group
}

resource "azurerm_resource_group" "testers" {
  name     = "${local.name_prefix}-TEST-RG"
  location = var.location
  tags     = local.common_tags
}

module "network_security_group" {
  source = "../../modules/network_security_group"

  name                       = "${local.prefix}-TEST-NSG"
  resource_group_name        = azurerm_resource_group.testers.name
  location                   = azurerm_resource_group.testers.location
  log_analytics_workspace_id = local.log_analytics_workspace_id
  tags                       = local.common_tags
}

### LINUX TEST VM ###

# Login is by SSH key. The private key is kept in the hub INFRA Key Vault; the
# identity running Terraform needs Key Vault Secrets Officer on that vault.
resource "tls_private_key" "linux" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "linux_ssh_private_key" {
  name         = "SSHKEY-${var.admin_username}-${local.name_prefix}-TEST-LINUX"
  value        = tls_private_key.linux.private_key_openssh
  content_type = "OpenSSH private key"
  key_vault_id = data.azurerm_key_vault.infra.id
  tags         = local.common_tags
}

resource "azurerm_network_interface" "linux" {
  name                = "${local.name_prefix}-ubuntu-linux-nic"
  location            = azurerm_resource_group.testers.location
  resource_group_name = azurerm_resource_group.testers.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "${local.name_prefix}-ubuntu-linux-nic"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "linux" {
  network_interface_id      = azurerm_network_interface.linux.id
  network_security_group_id = module.network_security_group.id
}

resource "azurerm_linux_virtual_machine" "linux" {
  name                  = "${local.name_prefix}-ubuntu-test-vm"
  location              = azurerm_resource_group.testers.location
  resource_group_name   = azurerm_resource_group.testers.name
  network_interface_ids = [azurerm_network_interface.linux.id]
  size                  = var.vm_size

  admin_username                  = var.admin_username
  disable_password_authentication = true
  secure_boot_enabled             = true
  vtpm_enabled                    = true

  custom_data = base64encode(templatefile("${path.module}/templates/debian_init.sh.tftpl", {
    http_proxy  = var.http_proxy == null ? "" : var.http_proxy
    https_proxy = var.https_proxy == null ? "" : var.https_proxy
  }))

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.linux.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  boot_diagnostics {}

  tags = merge(local.common_tags, { "${var.org_code}:operatingSystem" = "linux" })
}

### WINDOWS TEST VM ###

resource "random_password" "windows" {
  length           = 24
  min_lower        = 4
  min_upper        = 4
  min_numeric      = 4
  min_special      = 2
  override_special = "!@#$&"
}

resource "azurerm_key_vault_secret" "windows_admin_password" {
  name         = "PASSWORD-${var.admin_username}-${local.name_prefix}-TEST-WINDOWS"
  value        = random_password.windows.result
  content_type = "Local administrator password"
  key_vault_id = data.azurerm_key_vault.infra.id
  tags         = local.common_tags
}

resource "azurerm_network_interface" "windows" {
  name                = "${local.name_prefix}-windows-nic"
  location            = azurerm_resource_group.testers.location
  resource_group_name = azurerm_resource_group.testers.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "${local.name_prefix}-windows-nic"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "windows" {
  network_interface_id      = azurerm_network_interface.windows.id
  network_security_group_id = module.network_security_group.id
}

resource "azurerm_windows_virtual_machine" "windows" {
  name                  = "${local.name_prefix}-w-vm"
  computer_name         = "${local.loc_code}${local.env_code}TESTWIN" # NetBIOS limit: 15 characters
  location              = azurerm_resource_group.testers.location
  resource_group_name   = azurerm_resource_group.testers.name
  network_interface_ids = [azurerm_network_interface.windows.id]
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = random_password.windows.result

  secure_boot_enabled = true
  vtpm_enabled        = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  boot_diagnostics {}

  tags = merge(local.common_tags, { "${var.org_code}:operatingSystem" = "windows" })
}
