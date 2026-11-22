locals {
  # admin name to be assigned to all VMs
  admin_username = "vmadmin"
}

resource "azurerm_network_security_group" "windows_nsg" {
  name                = "${var.vm_name}-Win-NSG"
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
    destination_port_range     = "5986"
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

resource "azurerm_network_interface" "windows_vm_nic" {
  count               = var.num_vms
  name                = "${var.vm_name}-NIC${format("%03d", count.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.resource_group_name}-IP${format("%03d", count.index + 1)}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "windows_vm_nic" {
  count                        = var.num_vms
  network_interface_id         = element(azurerm_network_interface.windows_vm_nic.*.id, count.index)
  network_security_group_id    = azurerm_network_security_group.windows_nsg.id
}

data "azurerm_shared_image" "windows_image" {
  name                = var.windows_custom_image_name					# e.g. "pipeline-agent-ubuntu"
  gallery_name        = var.windows_custom_image_gallery_name			# "MyImageGalleryName"
  resource_group_name = var.windows_custom_image_gallery_rg_name		# "ImageGalleryResourceGroupName"

  provider = azurerm.image
     #mention alias to pull image into different subscription
}
resource "azurerm_windows_virtual_machine" "windows_vm" {
  count                 = var.num_vms
  name                  = "${var.vm_name}-win${format("%02d", count.index + 1)}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.windows_vm_nic[count.index].id]
  size                  = "Standard_D2_v2"
  admin_username        = local.admin_username
  admin_password        = var.admin_password
  source_image_id       = data.azurerm_shared_image.windows_image.id

  os_disk {
    
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb = "100"
  }

  winrm_listener {
    protocol = "Http"
  }
  
  tags = var.tags
}

