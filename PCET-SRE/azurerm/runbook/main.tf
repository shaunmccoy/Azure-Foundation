
resource "azurerm_automation_runbook" "runbook" {
  name                    = var.runbook_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = var.account_name
  log_verbose             = var.log_verbose
  log_progress            = var.log_progress
  description             = var.runbook_description
  runbook_type            = var.runbook_type
  tags                    = var.tags 

  content                 = var.runbook_content

}

resource "azurerm_automation_schedule" "schedule" {
  for_each                = var.schedule_config 
  name                    = each.key
  description             = try(each.value["description"], "")

  resource_group_name     = var.resource_group_name
  automation_account_name = var.account_name
  frequency               = each.value["frequency"]
  interval                = try(each.value["interval"], null)
  timezone                = try(each.value["timezone"], null)

  start_time              = try(each.value["start_time"], null)
  expiry_time             = try(each.value["expiry_time"], null)
  
  week_days               = try(each.value["week_days"], null)
  month_days              = try(each.value["month_days"], null)
}

resource "azurerm_automation_job_schedule" "job" {
  for_each                = var.schedule_config 

  resource_group_name     = var.resource_group_name
  automation_account_name = var.account_name
  schedule_name           = each.key
  runbook_name            = var.runbook_name
  run_on                  = var.hybrid_worker_group_name

  parameters              = try(each.value["parameters"], {})

}