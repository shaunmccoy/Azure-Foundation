output "prefix" {
  description = "Naming prefix for this business unit and environment."
  value       = local.prefix
}

output "hub_prefix" {
  description = "Naming prefix for the hub in this region and environment."
  value       = local.hub_prefix
}

output "common_tags" {
  description = "Standard tags to apply to every resource."
  value       = local.common_tags
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the central hub Log Analytics workspace."
  value       = local.log_analytics_workspace_id
}
