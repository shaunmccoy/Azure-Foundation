### FIREWALL RESOURCE GROUP ###

# Placeholder carried over from the original: it reserves the resource group for
# the Check Point firewalls that sit in the hub's Firewall-External and
# Firewall-Internal subnets. The firewall deployment itself is not defined here.
resource "azurerm_resource_group" "checkpoint" {
  name     = "${local.prefix}-CHECKPOINT-RG"
  location = var.location
  tags     = local.common_tags
}
