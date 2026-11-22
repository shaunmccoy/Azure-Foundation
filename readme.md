# Azure Foundation

Terraform for a hub-and-spoke Azure landing zone that runs in two regions: regional network
gateways, shared core services, a WAF-protected ingress per region, and a multi-region API
Management service behind it.

Targets Terraform 1.14+ (tested with 1.17.2) and the AzureRM provider 5.x (tested with 5.14.0).

```
                     api.example.com
                           |
                   Traffic Manager              configs/global-ingress
                  /                \
   Application Gateway        Application Gateway      configs/hub-appgateway (per region)
   WAF v2, Central US         WAF v2, East US 2
            |                         |
   API Management gateway --- API Management gateway   configs/apim (one service, two regions)
   3 units / 3 zones          3 units / 3 zones
            |                         |
        API spoke                 API spoke            configs/spoke
            |                         |
   Hub: ExpressRoute gateway, DNS, Key Vault, logs,    configs/hub-base (per region)
   registry, backup, private DNS
```

## Layout

| Path | What it deploys |
| --- | --- |
| `configs/hub-base` | Per-region hub: virtual network, ExpressRoute gateway (optional VPN), route tables, Log Analytics and Sentinel, Key Vaults, storage, Recovery Services vault, container registry, image gallery, central private DNS, CIS alerts, Defender plans, flow logs |
| `configs/hub-appgateway` | Per-region Application Gateway: WAF v2, zone-redundant, autoscaling, TLS from Key Vault |
| `configs/apim` | API Management: zone-redundant, multi-region, internal VNet mode, Key Vault certificates, Application Insights, alerts |
| `configs/global-ingress` | Traffic Manager across the regional Application Gateways |
| `configs/spoke` | Business-unit spoke: virtual network peered to the hub, route tables, Key Vaults, storage, optional Redis NSG and scale-set build agents |
| `configs/hub-adds`, `hub-infoblox`, `hub-checkpoint`, `hub-devopsagent`, `test-vm` | Domain controllers, DNS appliances, firewall resource group, build agents, connectivity test VMs |
| `modules/` | Reusable modules used by the configs |
| `pipelines/` | Azure DevOps plan / approve / apply pipelines |
| `scripts/validate.sh` | Format check, `terraform validate` and offline tests for everything |
| `docs/` | [Assessment and changes](docs/ASSESSMENT.md), [scrub report](docs/SCRUB-REPORT.md) |

Each config has `environments/*.tfvars`, one file per region and environment (`CUS-PROD`,
`EU2-PROD`, `CUS-UAT`, ...). All IDs, addresses and names in them are placeholders.

## Conventions

* Names: `<region code>-<business unit>-<environment code>-<purpose>`, e.g. `CUS-HUB-P-NET-RG`.
* Tags: `<org_code>:environment`, `<org_code>:costCenter`, ... Set `org_code` once per estate.
* `variables_common.tf` and `locals_common.tf` are identical in every config.
* No secrets in the repository. Sensitive inputs arrive as `TF_VAR_*` from the pipeline.
* Private endpoints register in the central private DNS zones through zone groups.

## Deployment order

1. `hub-base` for the production region first (it hosts the central private DNS zones), then every other hub.
2. `hub-infoblox` / `hub-adds`, if you run your own DNS and domain controllers.
3. `spoke` for each business unit and region.
4. `apim`, once the API spokes exist in both regions.
5. `hub-appgateway` in each region, then `global-ingress`.

## Running it

```bash
cd configs/hub-base
```

```bash
terraform init -backend-config="resource_group_name=<state-rg>" -backend-config="storage_account_name=<state-account>" -backend-config="container_name=tfstate" -backend-config="key=hub-base-CUS-PROD.terraform.tfstate" -backend-config="use_azuread_auth=true"
```

```bash
terraform plan -var-file=environments/CUS-PROD.tfvars
```

Check everything offline, with no Azure login:

```bash
scripts/validate.sh
```

Commit each config's `.terraform.lock.hcl` after your first `terraform init`.

## Before the first real deployment

* Replace every placeholder in `environments/*.tfvars` (subscriptions, tenant, address ranges, host names, email).
* Read [docs/ASSESSMENT.md](docs/ASSESSMENT.md): it lists what has not been proven against a live subscription.
* Rotate the credentials listed in [docs/SCRUB-REPORT.md](docs/SCRUB-REPORT.md).
