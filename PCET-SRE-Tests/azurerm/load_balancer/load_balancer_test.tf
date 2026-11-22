
resource "azurerm_resource_group" "test_rg" {
  name          = var.resource_group_name
  location      = var.location
  tags          = var.tags
}

resource "azurerm_virtual_network" "load_balancer" {
  name                = "load_balancer_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test_rg.location
  resource_group_name = azurerm_resource_group.test_rg.name
}

resource "azurerm_subnet" "load_balancer" {
  name                 = "load_balancer_subnet"
  resource_group_name  = azurerm_resource_group.test_rg.name
  virtual_network_name = azurerm_virtual_network.load_balancer.name
  address_prefixes     = ["10.0.1.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_network_interface" "testers" {
  name                = "fred-test-vm-NIC1"
  location            = azurerm_resource_group.test_rg.location
  resource_group_name = azurerm_resource_group.test_rg.name

  ip_configuration {
    name                          = "fred-test-vm-NIC1-IPConfig"
    subnet_id                     = azurerm_subnet.load_balancer.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.6"
  }
}

resource "azurerm_linux_virtual_machine" "testers" {
  name                  = "fred-test-vm"
  location              = azurerm_resource_group.test_rg.location
  resource_group_name   = azurerm_resource_group.test_rg.name
  network_interface_ids = [azurerm_network_interface.testers.id]
  size                  = "Standard_A2_v2"

  os_disk {
    name                 = "fred-test-vm-OS-DISK"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_username                  = "labadmin"
  admin_password                  = "REPLACE_ME"
  disable_password_authentication = false

}

module "load_balancer" {
    # source                          = "git::https://dev.azure.com/example-org/example-project/_git/PCET-SRE//azurerm/load_balancer?ref=load_balancer"
    source = "../../../PCET-SRE/azurerm/load_balancer"    

    backend_address_pool_list       = var.backend_address_pool_list
    frontend_ip_config              = var.frontend_ip_config
    nat_pool_config                 = var.nat_pool_config
    nat_rule_config                 = var.nat_rule_config
    probe_config                    = var.probe_config
    lb_rule_config                  = var.lb_rule_config
    load_balancer_name              = var.load_balancer_name
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    resource_group_name             = azurerm_resource_group.test_rg.name
    location                        = var.location
    tags                            = var.tags

}

resource "azurerm_network_interface_backend_address_pool_association" "example" {
  network_interface_id    = azurerm_network_interface.testers.id
  ip_configuration_name   = "fred-test-vm-NIC1-IPConfig"
  backend_address_pool_id = module.load_balancer.load_balancer_backend_pool_name_id_map["backend1"]
}

output "load_balancer_backend_pool_name_id_map" {
  value = module.load_balancer.load_balancer_backend_pool_name_id_map
}

output "nat_pool_name_id_map" {
  value = module.load_balancer.nat_pool_name_id_map
}

output "nat_rule_name_id_map" {
  value = module.load_balancer.nat_rule_name_id_map
}

output "probe_name_id_map" {
  value = module.load_balancer.probe_name_id_map
}