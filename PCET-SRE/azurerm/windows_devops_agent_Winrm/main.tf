locals {
  # admin name to be assigned to all agents
  admin_username = "azdoagent"
}

resource "azurerm_network_security_group" "windows_nsg" {
  name                = "${var.vm_name}-WinAGENT-NSG"
  location            =  var.location
  resource_group_name =  var.resource_group_name
  tags = var.tags

  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.100.0.0/15"
    destination_address_prefix = "10.100.0.0/15"
  }
  security_rule {
    name                       = "WinRM"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "10.100.0.0/15"
    destination_address_prefix = "10.100.0.0/15"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "10.100.0.0/15"
    destination_address_prefix = "10.100.0.0/15"
  }
}

resource "azurerm_network_interface" "agents" {
  count                           = var.num_agents
  name                            = "${var.resource_group_name}-NIC${format("%02d", count.index + 1)}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  

  ip_configuration {
    name                            = "${var.resource_group_name}-IP${format("%02d", count.index + 1)}"
    subnet_id                       = var.subnet_id
    private_ip_address_allocation   = "Dynamic"
  }
  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "agent" {
  count                        = var.num_agents
  network_interface_id         = element(azurerm_network_interface.agents.*.id, count.index)
  network_security_group_id    = azurerm_network_security_group.windows_nsg.id
}

data "azurerm_key_vault" "devopspwd" {
  name                = "example-devops-kv"
  resource_group_name = "example-devops-rg"

  provider = azurerm.key
}

data "azurerm_key_vault_secret" "mySecret" {
  name = "admin-pwd"
  key_vault_id = data.azurerm_key_vault.devopspwd.id

  provider = azurerm.key
}

data "azurerm_shared_image" "windows_image" {
  name                = var.windows_custom_image_name					# e.g. "pipeline-agent-ubuntu"
  gallery_name        = var.windows_custom_image_gallery_name			# "MyImageGalleryName"
  resource_group_name = var.windows_custom_image_gallery_rg_name		# "ImageGalleryResourceGroupName"

  provider = azurerm.image
}

resource "azurerm_windows_virtual_machine" "windows_vm" {
  count                 = var.num_agents
  admin_username        = local.admin_username
  admin_password        = data.azurerm_key_vault_secret.mySecret.value
  name                  = "${substr(var.vm_name, 0, 4)}-WinAGENT${format("%02d", count.index + 1)}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.agents[count.index].id]
  size                  = "Standard_D2_v2"
  provision_vm_agent    = "true"
  timezone              = "Romance Standard Time"
  source_image_id       = data.azurerm_shared_image.windows_image.id
  tags = var.tags

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  winrm_listener {
    protocol = "Http"
  }
  }

data "azurerm_subscription" "main" {}

 resource "null_resource" "winrmconfig" {
  count            = var.num_agents
  depends_on       = [azurerm_windows_virtual_machine.windows_vm]
  provisioner "local-exec" {
            
            environment = {
      SUBSCRIPTION_ID = "data.azurerm_subscription.main.id" 
    }
            command     = "az login --identity\naz account set --subscription ${data.azurerm_subscription.main.subscription_id}\naz vm run-command invoke  --command-id RunPowerShellScript --name ${azurerm_windows_virtual_machine.windows_vm[count.index].name} -g ${var.resource_group_name} --scripts @winrm.ps1 --subscription ${data.azurerm_subscription.main.subscription_id}"
  }
 }