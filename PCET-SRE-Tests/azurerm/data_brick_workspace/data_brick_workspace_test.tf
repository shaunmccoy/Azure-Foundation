
resource "azurerm_resource_group" "test_rg" {
  name          = var.resource_group_name
  location      = var.location
  tags          = var.tags
}

resource "azurerm_virtual_network" "data_bricks" {
  name                = "data_brick_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test_rg.location
  resource_group_name = azurerm_resource_group.test_rg.name
}

resource "azurerm_route_table" "route" {
  name                = "DataBricks-internetRoutes"
  location            = azurerm_resource_group.test_rg.location
  resource_group_name = azurerm_resource_group.test_rg.name
}

resource "azurerm_route" "internet_routes" {
  count               = length(var.databricks_internet_cidr_list)
  name                = "internet-route-${count.index}"
  resource_group_name = azurerm_resource_group.test_rg.name
  route_table_name    = azurerm_route_table.route.name
  address_prefix      = var.databricks_internet_cidr_list[count.index]
  next_hop_type       = "Internet"
}

resource "azurerm_subnet" "public_subnet" {
  name                 = "data_brick_public"
  resource_group_name  = azurerm_resource_group.test_rg.name
  virtual_network_name = azurerm_virtual_network.data_bricks.name
  address_prefixes     = ["10.0.1.0/24"]

  enforce_private_link_endpoint_network_policies = true

  delegation {
    name = "databrickdelegation"
    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
          "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

resource "azurerm_network_security_group" "private_subnet_nsg" {
  name                = "data_brick_nsg"
  location            = azurerm_resource_group.test_rg.location
  resource_group_name = azurerm_resource_group.test_rg.name
}

resource "azurerm_subnet" "private_subnet" {
  name                 = "data_brick_private"
  resource_group_name  = azurerm_resource_group.test_rg.name
  virtual_network_name = azurerm_virtual_network.data_bricks.name
  address_prefixes     = ["10.0.2.0/24"]

  enforce_private_link_endpoint_network_policies = true

  delegation {
    name = "databrickdelegation"
    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
          "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "private_subnet_nsg" {
  subnet_id                 = azurerm_subnet.private_subnet.id
  network_security_group_id = azurerm_network_security_group.private_subnet_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "public_subnet_nsg" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.private_subnet_nsg.id
}

resource "azurerm_subnet_route_table_association" "private_subnet_routes" {
  subnet_id      = azurerm_subnet.private_subnet.id
  route_table_id = azurerm_route_table.route.id
}

resource "azurerm_subnet_route_table_association" "public_subnet_routes" {
  subnet_id      = azurerm_subnet.public_subnet.id
  route_table_id = azurerm_route_table.route.id
}

module "data_brick_workspace" {
    # source                          = "git::https://dev.azure.com/example-org/example-project/_git/PCET-SRE//azurerm/data_brick_workspace?ref=data_factory"
    source = "../../../PCET-SRE/azurerm/data_brick_workspace"    

    virtual_network_id              = azurerm_virtual_network.data_bricks.id
    public_subnet_name              = azurerm_subnet.public_subnet.name
    private_subnet_name             = azurerm_subnet.private_subnet.name

    data_brick_workspace_name       = var.data_brick_workspace_name
    managed_resource_group_name     = "${var.data_brick_workspace_name}-rg"
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    resource_group_name             = azurerm_resource_group.test_rg.name
    location                        = var.location
    tags                            = var.tags

}