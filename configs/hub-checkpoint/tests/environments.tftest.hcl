# Plans every environments/*.tfvars file against a mocked provider (scripts/validate.sh
# passes each file with -var-file). Secrets that normally arrive as TF_VAR_* get dummy values.
mock_provider "azurerm" {}

run "plans_with_environment_file" {
  command = plan
}
