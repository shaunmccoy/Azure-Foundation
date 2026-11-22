# Scale set shaped for Azure DevOps "scale set agent" pools: manual upgrade mode,
# no overprovisioning, single placement group off, capacity changes ignored.
resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  instances           = var.instances
  zones               = var.zones
  tags                = var.tags

  admin_username                  = var.admin_username
  disable_password_authentication = true
  custom_data                     = var.custom_data
  source_image_id                 = var.source_image_id

  upgrade_mode           = "Manual"
  overprovision          = false
  single_placement_group = false
  secure_boot_enabled    = true
  vtpm_enabled           = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "StandardSSD_LRS"
  }

  network_interface {
    name    = "${var.name}-NIC"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id
    }
  }

  # Managed boot diagnostics: no storage account or access key needed.
  boot_diagnostics {}

  dynamic "plan" {
    for_each = var.plan == null ? [] : [var.plan]

    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) == 0 ? [] : [1]

    content {
      type         = "UserAssigned"
      identity_ids = var.identity_ids
    }
  }

  lifecycle {
    # Azure DevOps scales the pool and tags instances it owns.
    ignore_changes = [instances, tags["__AzureDevOpsElasticPool"], tags["__AzureDevOpsElasticPoolTimeStamp"]]
  }
}
