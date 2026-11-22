output "id" {
  description = "Compute gallery resource ID."
  value       = azurerm_shared_image_gallery.this.id
}

output "name" {
  description = "Compute gallery name."
  value       = azurerm_shared_image_gallery.this.name
}

output "image_definition_ids" {
  description = "Map of image definition name to resource ID."
  value       = { for name, image in azurerm_shared_image.this : name => image.id }
}
