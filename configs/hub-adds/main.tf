### LOOKUPS (created by hub-base) ###

data "azurerm_subnet" "active_directory" {
  name                 = "ActiveDirectory"
  virtual_network_name = local.hub_names.vnet
  resource_group_name  = local.hub_names.network_resource_group
}

data "azurerm_key_vault" "infra" {
  name                = local.hub_names.infra_keyvault
  resource_group_name = local.hub_names.keyvault_resource_group
}

### ACTIVE DIRECTORY DOMAIN SERVICES ###

resource "azurerm_resource_group" "adds" {
  name     = "${local.prefix}-ADDS-RG"
  location = var.location
  tags     = local.common_tags
}

module "network_security_group" {
  source = "../../modules/network_security_group"

  name                       = "${local.prefix}-ADDS-NSG"
  resource_group_name        = azurerm_resource_group.adds.name
  location                   = azurerm_resource_group.adds.location
  log_analytics_workspace_id = local.log_analytics_workspace_id
  tags                       = local.common_tags
}

resource "azurerm_network_security_rule" "adds" {
  for_each = local.adds_rules

  name                        = each.key
  priority                    = each.value.priority
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_port_ranges     = each.value.ports
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.adds.name
  network_security_group_name = module.network_security_group.name
}

# One generated local administrator password per domain controller, kept in the
# hub INFRA Key Vault. The identity running Terraform needs Key Vault Secrets
# Officer on that vault and network line of sight to its private endpoint.
resource "random_password" "admin" {
  for_each = local.domain_controllers

  length           = 24
  min_lower        = 4
  min_upper        = 4
  min_numeric      = 4
  min_special      = 2
  override_special = "!@#$&"
}

resource "azurerm_key_vault_secret" "admin_password" {
  for_each = local.domain_controllers

  name         = "PASSWORD-${var.admin_username}-${each.key}"
  value        = random_password.admin[each.key].result
  content_type = "Local administrator password"
  key_vault_id = data.azurerm_key_vault.infra.id
  tags         = local.common_tags
}

resource "azurerm_network_interface" "adds" {
  for_each = local.domain_controllers

  name                = "${each.key}-NIC"
  location            = azurerm_resource_group.adds.location
  resource_group_name = azurerm_resource_group.adds.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "${each.key}-IPConfig01"
    subnet_id                     = data.azurerm_subnet.active_directory.id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.ip_address
  }
}

resource "azurerm_monitor_diagnostic_setting" "network_interface" {
  for_each = local.domain_controllers

  name                       = "LOGANALYTICS-DIAGNOSTICS"
  target_resource_id         = azurerm_network_interface.adds[each.key].id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_network_interface_security_group_association" "adds" {
  for_each = local.domain_controllers

  network_interface_id      = azurerm_network_interface.adds[each.key].id
  network_security_group_id = module.network_security_group.id
}

resource "azurerm_windows_virtual_machine" "adds" {
  for_each = local.domain_controllers

  name                  = each.key
  location              = azurerm_resource_group.adds.location
  resource_group_name   = azurerm_resource_group.adds.name
  size                  = var.vm_size
  zone                  = each.value.zone
  admin_username        = var.admin_username
  admin_password        = random_password.admin[each.key].result
  network_interface_ids = [azurerm_network_interface.adds[each.key].id]

  secure_boot_enabled = true
  vtpm_enabled        = true

  source_image_reference {
    publisher = var.windows_image.publisher
    offer     = var.windows_image.offer
    sku       = var.windows_image.sku
    version   = var.windows_image.version
  }

  os_disk {
    name                 = "${each.key}-OS-Disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  # Managed boot diagnostics: no storage account or access key needed.
  boot_diagnostics {}

  tags = merge(local.common_tags, { "${var.org_code}:operatingSystem" = "windows" })
}

resource "azurerm_managed_disk" "adds" {
  for_each = local.domain_controllers

  name                 = "${each.key}-Data-Disk01"
  location             = azurerm_resource_group.adds.location
  resource_group_name  = azurerm_resource_group.adds.name
  zone                 = each.value.zone
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
  tags                 = local.common_tags
}

# Host caching must be off for the disk that holds NTDS and SYSVOL.
resource "azurerm_virtual_machine_data_disk_attachment" "adds" {
  for_each = local.domain_controllers

  managed_disk_id    = azurerm_managed_disk.adds[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.adds[each.key].id
  lun                = 0
  caching            = "None"
}
