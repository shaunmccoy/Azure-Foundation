
resource "azurerm_resource_group" "test_rg" {
  name          = var.resource_group_name
  location      = var.location
  tags          = var.tags
}

resource "azurerm_virtual_network" "data_factory" {
  name                = "data_factory_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test_rg.location
  resource_group_name = azurerm_resource_group.test_rg.name
}

resource "azurerm_subnet" "data_factory" {
  name                 = "data_factory_subnet"
  resource_group_name  = azurerm_resource_group.test_rg.name
  virtual_network_name = azurerm_virtual_network.data_factory.name
  address_prefixes     = ["10.0.1.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

module "data_factory" {
    # source                          = "git::https://dev.azure.com/example-org/example-project/_git/PCET-SRE//azurerm/data_factory?ref=data_factory"
    source = "../../../PCET-SRE/azurerm/data_factory"    

    deployment_name                 = var.deployment_name
    subscription_id                 = var.subscription_id
    subnet_id                       = azurerm_subnet.data_factory.id
    private_endpoint_name           = var.private_endpoint_name
    data_factory_name               = var.data_factory_name
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    resource_group_name             = azurerm_resource_group.test_rg.name
    location                        = var.location
    devops_account_name             = var.devops_account_name
    devops_project_name             = var.devops_project_name
    devops_repo_name                = var.devops_repo_name
    devops_branch_name              = var.devops_branch_name
    tags                            = var.tags

}