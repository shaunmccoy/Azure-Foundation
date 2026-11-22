locals {
  hybrid_worker_group_name = "${var.account_name}-WG"
}

resource "azurerm_resource_group" "test_rg" {
  name          = var.resource_group_name
  location      = var.location
  tags          = var.tags
}

module "automation_environment" {
    # source                          = "git::https://dev.azure.com/example-org/example-project/_git/PCET-SRE//azurerm/loganalytics_workspace?ref=load_balancer"
    source = "../../../PCET-SRE/azurerm/automation_environment"    

    account_name                  = var.account_name
    worker_scale_set_name         = "${var.account_name}-SS"
    worker_scale_set_nic_name     = "${var.account_name}-NIC"
    worker_subnet_id              = "/subscriptions/10000000-0000-0000-0000-000000000002/resourceGroups/client-device-rg/providers/Microsoft.Network/virtualNetworks/client-device-VNET-centralus/subnets/Main"
    worker_admin_public_key       = file("~/.ssh/id_rsa.pub")
    hybrid_worker_group_name      = local.hybrid_worker_group_name
    worker_managed_id_list        = var.worker_managed_id_list

    http_proxy                    = ""
    https_proxy                   = ""
    no_proxy_udr                  = ""

    resource_group_name           = azurerm_resource_group.test_rg.name
    location                      = azurerm_resource_group.test_rg.location
    log_analytics_workspace_name  = "${var.account_name}-WORKSPACE"
    tags                          = var.tags
    
}

module "runbook" {
    source = "../../../PCET-SRE/azurerm/runbook"  

    runbook_name                  = var.runbook_name
    runbook_description           = var.runbook_description
    runbook_content               = file("${path.module}/runbook-test.PS1")
    account_name                  = var.account_name
    runbook_type                  = var.runbook_type
    schedule_config               = var.schedule_config
    hybrid_worker_group_name      = local.hybrid_worker_group_name
    
    resource_group_name           = azurerm_resource_group.test_rg.name
    location                      = azurerm_resource_group.test_rg.location
    tags                          = var.tags
}
