locals {
    log_category_map = {
          for category in var.diagnostic_log_category_list:
              category => category
    }

    # dynamic blocks only use maps.  In this case, only one entry permitted.
    managed_id_map = length(var.worker_managed_id_list) > 0 ? {one = "one"} : {}

}

resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                =  var.log_analytics_workspace_name
  location            =  var.location
  resource_group_name =  var.resource_group_name
  sku                 =  var.log_analytics_workspace_sku
  retention_in_days   =  var.log_analytics_retention_days
}

resource "azurerm_automation_account" "account" {
  name                = var.account_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name            = var.account_sku_name

  tags                = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "account_diag" {
  name                            = var.diagnostics_name
  depends_on                      = [ azurerm_automation_account.account ]

  target_resource_id              = azurerm_automation_account.account.id
  log_analytics_workspace_id      = azurerm_log_analytics_workspace.log_analytics.id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days = var.diagnostics_retention_days
    }
  }
  
  dynamic "log" {
    for_each = local.log_category_map
    content {
        category = log.key
        enabled  = true

        retention_policy {
          enabled = true
          days = var.diagnostics_retention_days
        }
    }
  }
  
}

resource "azurerm_log_analytics_linked_service" "account_diag_service" {
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics.id
  read_access_id      = azurerm_automation_account.account.id
}

resource "azurerm_log_analytics_solution" "solution" {
  solution_name         = "AzureAutomation"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureAutomation"
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "automation_vm_ss" {
  name                = var.worker_scale_set_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.worker_scale_set_sku
  instances           = var.worker_scale_set_vm_count
  admin_username      = var.worker_admin_username

  tags                = var.tags

  dynamic "identity" {
    for_each = local.managed_id_map
    content {
      type = "UserAssigned"
      identity_ids = var.worker_managed_id_list
    }
  }

  custom_data = base64encode(templatefile("${path.module}/debian_init.sh.template", {
      http_proxy = var.http_proxy
      https_proxy = var.https_proxy
      no_proxy_udr = var.no_proxy_udr
      workspace_id = azurerm_log_analytics_workspace.log_analytics.workspace_id
      workspace_primary_key = azurerm_log_analytics_workspace.log_analytics.primary_shared_key
      account_shared_key = azurerm_automation_account.account.dsc_primary_access_key
      account_endpoint = azurerm_automation_account.account.dsc_server_endpoint
      hybrid_worker_group_name = var.hybrid_worker_group_name
      adminuser = var.worker_admin_username
    }))

  admin_ssh_key {
    username   = var.worker_admin_username
    public_key = var.worker_admin_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = var.worker_scale_set_nic_name
    primary = true

    ip_configuration {
      name      = var.worker_scale_set_nic_name
      primary   = true
      subnet_id = var.worker_subnet_id
    }
  }

}