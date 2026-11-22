resource "azurerm_shared_image_gallery" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "Shared golden images"
  tags                = var.tags
}

resource "azurerm_shared_image" "this" {
  for_each = var.image_definitions

  name                = each.key
  gallery_name        = azurerm_shared_image_gallery.this.name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = each.value.os_type
  tags                = var.tags

  # Generation 2 with Trusted Launch is the default for new Azure VMs.
  hyper_v_generation     = "V2"
  trusted_launch_enabled = true

  identifier {
    publisher = var.publisher
    offer     = coalesce(each.value.offer, "${var.publisher}-GoldenImage")
    sku       = each.value.sku
  }
}
