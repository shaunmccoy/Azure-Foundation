# Self-hosted Azure Pipelines agents on plain Linux VMs, registered with a PAT at first boot.
#
# This is kept for parity with the existing estate. For new pools prefer Managed DevOps
# Pools, or scale-set agents (modules/linux_scaleset) with a managed identity: neither
# needs a long-lived PAT in VM custom data.

locals {
  agents = { for i in range(var.num_agents) : format("%02d", i + 1) => i }

  no_proxy = join(",", compact([var.no_proxy, "169.254.169.254", "168.63.129.16"]))

  # A changed PAT or script must not rebuild running agents; see lifecycle below.
  custom_data = {
    for key, i in local.agents : key => base64encode(templatefile("${path.module}/${var.linux_dialect}_init.sh.tftpl", {
      agent_user          = var.admin_username
      agent_name          = "${var.vm_name_prefix}AGT${key}"
      agent_version       = var.agent_version
      devops_url          = var.devops_url
      agent_pat           = var.agent_pat_token
      agent_pool_name     = var.agent_pool_name
      devops_project_name = var.devops_project_name
      http_proxy          = var.http_proxy == null ? "" : var.http_proxy
      https_proxy         = var.https_proxy == null ? "" : var.https_proxy
      no_proxy            = local.no_proxy
      nbr_agents          = var.agents_per_vm
    }))
  }
}

module "network_security_group" {
  source = "../network_security_group"

  name                       = var.nsg_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = var.tags
}

resource "azurerm_network_interface" "agents" {
  for_each = local.agents

  name                = "${var.vm_name_prefix}-DEVOPSAGENT-NIC${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "${var.vm_name_prefix}-DEVOPSAGENT-IP${each.key}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_monitor_diagnostic_setting" "network_interface" {
  for_each = local.agents

  name                       = "LOGANALYTICS-DIAGNOSTICS"
  target_resource_id         = azurerm_network_interface.agents[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_network_interface_security_group_association" "agents" {
  for_each = local.agents

  network_interface_id      = azurerm_network_interface.agents[each.key].id
  network_security_group_id = module.network_security_group.id
}

resource "azurerm_linux_virtual_machine" "agents" {
  for_each = local.agents

  name                  = "${var.vm_name_prefix}DEVAGT${each.key}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.agents[each.key].id]
  size                  = var.agent_vm_size
  zone                  = length(var.zones) == 0 ? null : var.zones[each.value % length(var.zones)]
  custom_data           = local.custom_data[each.key]
  tags                  = var.tags

  admin_username                  = var.admin_username
  disable_password_authentication = true
  secure_boot_enabled             = true
  vtpm_enabled                    = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    name                 = "${var.vm_name_prefix}DEVAGT${each.key}-OSDisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = var.linux_image.publisher
    offer     = var.linux_image.offer
    sku       = var.linux_image.sku
    version   = var.linux_image.version
  }

  # Managed boot diagnostics: no storage account or access key needed.
  boot_diagnostics {}

  dynamic "identity" {
    for_each = length(var.managed_identity_ids) == 0 ? [] : [1]

    content {
      type         = "UserAssigned"
      identity_ids = var.managed_identity_ids
    }
  }

  lifecycle {
    # custom_data only runs at first boot. Rotating the PAT or editing the init
    # script should not destroy registered agents; taint a VM to rebuild it.
    ignore_changes = [custom_data]
  }
}
