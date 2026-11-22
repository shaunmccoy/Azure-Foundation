### LOOKUPS (created by hub-base) ###

data "azurerm_subnet" "infoblox" {
  name                 = "InfoBlox"
  virtual_network_name = local.hub_names.vnet
  resource_group_name  = local.hub_names.network_resource_group
}

data "azurerm_key_vault" "infra" {
  name                = local.hub_names.infra_keyvault
  resource_group_name = local.hub_names.keyvault_resource_group
}

### INFOBLOX DNS / DHCP / IPAM APPLIANCES ###

resource "azurerm_resource_group" "infoblox" {
  name     = "${local.prefix}-INFOBLOX-RG"
  location = var.location
  tags     = local.common_tags
}

# Replaces the manual `az vm image terms accept` step.
resource "azurerm_marketplace_agreement" "infoblox" {
  count = var.accept_marketplace_terms ? 1 : 0

  publisher = var.infoblox_image.publisher
  offer     = var.infoblox_image.offer
  plan      = var.infoblox_image.sku
}

module "network_security_group" {
  source = "../../modules/network_security_group"

  name                       = "${local.prefix}-INFOBLOX-NSG"
  resource_group_name        = azurerm_resource_group.infoblox.name
  location                   = azurerm_resource_group.infoblox.location
  log_analytics_workspace_id = local.log_analytics_workspace_id
  tags                       = local.common_tags
}

resource "azurerm_network_security_rule" "infoblox" {
  for_each = local.infoblox_rules

  name                        = each.key
  priority                    = each.value.priority
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_port_range      = each.value.port
  source_address_prefix       = length(each.value.sources) == 0 ? "VirtualNetwork" : null
  source_address_prefixes     = length(each.value.sources) == 0 ? null : each.value.sources
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.infoblox.name
  network_security_group_name = module.network_security_group.name
}

# One generated administrator password per appliance, kept in the hub INFRA Key
# Vault. The identity running Terraform needs Key Vault Secrets Officer on that
# vault and network line of sight to its private endpoint.
resource "random_password" "admin" {
  for_each = local.appliances

  length           = 24
  min_lower        = 4
  min_upper        = 4
  min_numeric      = 4
  min_special      = 2
  override_special = "!@#$&"
}

resource "azurerm_key_vault_secret" "admin_password" {
  for_each = local.appliances

  name         = "PASSWORD-${var.admin_username}-${each.value.name}"
  value        = random_password.admin[each.key].result
  content_type = "Appliance administrator password"
  key_vault_id = data.azurerm_key_vault.infra.id
  tags         = local.common_tags
}

resource "azurerm_network_interface" "infoblox" {
  for_each = local.appliances

  name                = "${local.prefix}-INFOBLOX-NIC${each.key}"
  location            = azurerm_resource_group.infoblox.location
  resource_group_name = azurerm_resource_group.infoblox.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "${local.prefix}-INFOBLOX-NIC${each.key}-IPConfig01"
    subnet_id                     = data.azurerm_subnet.infoblox.id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.ip_address
  }
}

resource "azurerm_monitor_diagnostic_setting" "network_interface" {
  for_each = local.appliances

  name                       = "LOGANALYTICS-DIAGNOSTICS"
  target_resource_id         = azurerm_network_interface.infoblox[each.key].id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_network_interface_security_group_association" "infoblox" {
  for_each = local.appliances

  network_interface_id      = azurerm_network_interface.infoblox[each.key].id
  network_security_group_id = module.network_security_group.id
}

resource "azurerm_linux_virtual_machine" "infoblox" {
  for_each = local.appliances

  name                  = each.value.name
  location              = azurerm_resource_group.infoblox.location
  resource_group_name   = azurerm_resource_group.infoblox.name
  size                  = var.vm_size
  zone                  = each.value.zone
  network_interface_ids = [azurerm_network_interface.infoblox[each.key].id]
  tags                  = local.common_tags

  # NIOS does not use Azure SSH key provisioning; Azure still requires credentials.
  admin_username                  = var.admin_username
  admin_password                  = random_password.admin[each.key].result
  disable_password_authentication = false

  secure_boot_enabled = var.trusted_launch_enabled ? true : null
  vtpm_enabled        = var.trusted_launch_enabled ? true : null

  source_image_reference {
    publisher = var.infoblox_image.publisher
    offer     = var.infoblox_image.offer
    sku       = var.infoblox_image.sku
    version   = var.infoblox_image.version
  }

  plan {
    name      = var.infoblox_image.sku
    publisher = var.infoblox_image.publisher
    product   = var.infoblox_image.offer
  }

  os_disk {
    name                 = "${each.value.name}-OS-Disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  # Managed boot diagnostics: no storage account or access key needed.
  boot_diagnostics {}

  depends_on = [azurerm_marketplace_agreement.infoblox]
}

resource "azurerm_managed_disk" "infoblox" {
  for_each = local.appliances

  name                 = "${each.value.name}-Data-Disk01"
  location             = azurerm_resource_group.infoblox.location
  resource_group_name  = azurerm_resource_group.infoblox.name
  zone                 = each.value.zone
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
  tags                 = local.common_tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "infoblox" {
  for_each = local.appliances

  managed_disk_id    = azurerm_managed_disk.infoblox[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.infoblox[each.key].id
  lun                = 0
  caching            = "ReadOnly"
}
