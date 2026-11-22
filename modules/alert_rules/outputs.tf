output "action_group_id" {
  description = "Action group resource ID, for reuse by other alerts."
  value       = azurerm_monitor_action_group.this.id
}
