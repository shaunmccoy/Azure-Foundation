# Azure Foundation

Terraform foundation for Azure spoke subscriptions. It works out the shared
naming prefixes, the standard tags and the hub Log Analytics workspace ID that
every other resource or module in a business unit's subscription should use.

## Layout

| Path | Purpose |
| --- | --- |
| `.configs/.INFR/` | Root configuration: versions, provider, variables, naming/tag locals, outputs |
| `.configs/.INFR/tests/` | Offline `terraform test` suite (mocked provider, no Azure login needed) |
| `.modules/.storage_accounts/` | Placeholder for a storage account module (not written yet) |

## What it produces

Given `location = "eastus2"`, `env = "prod"` and `business_unit = "FIN"`:

| Output | Example |
| --- | --- |
| `prefix` | `EUS2-FIN-PRD` |
| `hub_prefix` | `EUS2-HUB-PRD` |
| `log_analytics_workspace_id` | `/subscriptions/<hub>/resourceGroups/EUS2-HUB-PRD-logs-rg/providers/Microsoft.OperationalInsights/workspaces/EUS2-HUB-PRD-azloganalytics` |
| `common_tags` | `sm:tla`, `sm:ecosystem`, `sm:datacenter`, `sm:environment`, `sm:subnettype`, `sm:resourceclass`, `sm:costcenter`, `sm:businessunit` |

## Requirements

* Terraform `>= 1.14` (tested with 1.17.2)
* AzureRM provider `~> 5.14`
* Azure CLI 2.x signed in (`az login`), or a service principal / workload identity (OIDC) through `ARM_*` environment variables

## Usage

```bash
cd .configs/.INFR
cp terraform.tfvars.example terraform.tfvars   # then edit
az login
terraform init
terraform test       # offline checks
terraform plan
```

Commit `.terraform.lock.hcl` after the first `terraform init`. To make it valid
on every platform your team and CI use, run:

```bash
terraform providers lock -platform=linux_amd64 -platform=darwin_arm64 -platform=windows_amd64
```

### CI (GitHub Actions / Azure DevOps)

Use OIDC workload identity federation rather than client secrets:

```bash
export ARM_USE_OIDC=true
export ARM_CLIENT_ID=<app-id>
export ARM_TENANT_ID=<tenant-id>
export ARM_SUBSCRIPTION_ID=<subscription-id>
```

### Remote state

Add an `azurerm` backend before using this for real, with Entra ID auth instead of storage keys:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "<state-rg>"
    storage_account_name = "<statestorage>"
    container_name       = "tfstate"
    key                  = "infr.tfstate"
    use_azuread_auth     = true
  }
}
```

## Notes for azurerm 5.x

* Resource Providers are **no longer registered automatically**. Register
  `Microsoft.Storage`, `Microsoft.OperationalInsights` and `Microsoft.Insights`
  once per subscription (`az provider register --namespace Microsoft.Storage`),
  or uncomment `resource_providers_to_register` in `providers.tf`.
* `storage_use_azuread = true` is set, so the identity running Terraform needs
  data-plane RBAC (for example *Storage Blob Data Contributor*) on storage accounts.
* For the upcoming storage module: `min_tls_version` must be `TLS1_2`,
  `allow_nested_items_to_be_public` now defaults to `false`, and the
  `static_website` / `queue_properties` blocks were replaced by separate resources.
* Diagnostic settings must use `enabled_log` / `enabled_metric` blocks (the
  `metric` and `retention_policy` blocks were removed).
