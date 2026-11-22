# Assessment and changes

This repository was rebuilt from an older codebase written for Terraform 0.12/0.13 and AzureRM
2.x. This note records what that code did, what was missing, and what changed.

## Was there a multi-region model?

Partly. The original deployed **independent regional copies** by running the same config with a
different variable file: Central US for every environment, plus East US 2 as production DR.

| Area | Original | Now |
| --- | --- | --- |
| Network gateway | ExpressRoute gateway per hub, each connected to its own circuit and the other region's. Non-zonal SKU, Basic dynamic public IP. A VPN gateway module existed but nothing used it. | Zone-redundant ExpressRoute gateway (`ErGw*AZ`), Standard zonal IP, weighted primary/secondary connections. VPN gateway is an option in `hub-base` (active-active, zone-redundant, IKEv2 with an explicit policy). |
| Application Gateway | One `Standard_v2` gateway with two fixed instances, a single plain-HTTP listener, no WAF, no zones, no health probes, pointing at a test static site. The East US 2 variable file had no dot in its name, so it could not be loaded. | `WAF_v2` with a managed-rule policy, three zones, autoscaling, HTTPS from Key Vault, HTTP-to-HTTPS redirect, probes, TLS 1.2+ policy. |
| Global routing | None. Nothing connected the two regions for clients. | `configs/global-ingress`: Traffic Manager over the regional gateways. |
| API Management | No API Management service. One spoke had an API Management subnet and route table only. | `modules/api_management` and `configs/apim` (new code, see below). |
| Core services | Log Analytics, three Key Vaults, three storage accounts, Recovery Services vault, container registry, image gallery, managed identity, CIS alerts, Defender, private DNS. Present per region. | Same set, hardened (below). Registry can geo-replicate. |
| Private DNS | Hand-written A records in the production zone, through a provider with a hard-coded subscription ID. | Private endpoints register themselves through DNS zone groups. |

## API Management

`modules/api_management` is new. The originals contained no API Management service, so this is
not a port; reconcile it with any existing API Management code you have elsewhere.

* **Availability:** Premium tier, units spread over three zones, a gateway in each additional region. Validation rejects unit counts that do not divide across zones and multi-region on the Developer tier.
* **Network:** internal VNet mode. The module builds the NSG the service needs in each region and attaches it before the service is created.
* **Security:** TLS 1.2+ with weak ciphers off towards clients and backends, management API key access off, portal sign-up off, minimum management API version pinned, certificates and named values read from Key Vault with a managed identity.
* **Observability:** resource logs to Log Analytics, Application Insights with W3C correlation and Entra ID ingestion, alerts for capacity, 5xx, slow backends, unauthorized spikes and Azure Resource Health.
* **Safety:** delete lock on by default, soft-deleted services are recovered rather than purged, a per-region switch to take a gateway out of rotation for failover drills.

Things to know:

* The management plane, developer portal and configuration live in the primary region only. If that region is lost, other regions keep serving with the last configuration, but nothing can be changed until it returns.
* Every regional subnet of a multi-region instance has to be in the instance's own subscription. The original kept production and DR spokes in separate subscriptions, so the East US 2 API spoke is now deployed into the production API subscription (`subscription_baseline_enabled = false` avoids duplicate subscription-wide settings). Confirm this constraint against current Microsoft documentation for your case.
* Creating or adding a region to a VNet-injected service often takes more than an hour.
* APIs, products and policies are not defined here.

## Other changes

* **Structure:** seven near-identical spoke configs became one `spoke` config with a variable file per business unit. `hub_vnet` and `vnet` (identical) merged. `storage_account` and `storage_account_privatelink` merged. The unused, broken `active_directory_vm` module was dropped; `hub-adds` builds the domain controllers.
* **Provider 5.x:** diagnostic settings use `enabled_log` / `enabled_metric`; removed and renamed arguments replaced throughout; resource providers are registered explicitly.
* **Key Vault:** Azure RBAC instead of access policies, purge protection on, public access off.
* **Storage:** TLS 1.2, no shared keys, no public blobs, zone-redundant where zones exist, versioning on state accounts.
* **Logging:** legacy Log Analytics solutions replaced by Sentinel onboarding and subscription activity-log export; virtual network flow logs replace NSG flow logs.
* **Container registry:** admin account off (its password used to be a Terraform output), public access off, private endpoint, zone redundancy.
* **Virtual machines:** current resources and images, zones instead of availability sets, SSH keys and generated passwords kept in Key Vault, managed boot diagnostics.
* **Pipelines:** five pipelines and twelve templates became two pipelines and one template. They no longer print the storage key or the full environment to the log, verify the Terraform download, use Entra ID for state, and apply the reviewed plan after an approval.
* **Naming:** storage account names use the one-letter environment code so they fit in 24 characters for every environment. Routes and rules are keyed by name instead of list position.

## Not verified

* Nothing here has been planned or applied against a real subscription. Checks were `terraform validate` plus plans against a mocked provider for every variable file.
* This is a new baseline, not an in-place upgrade: resource addresses and several names changed, so existing state cannot simply be re-pointed at it.
* The hub DNS servers must forward the `privatelink.*` and internal zones to Azure DNS (168.63.129.16) for private endpoints and the Application Gateway backends to resolve.
* New virtual networks no longer get implicit outbound Internet access. Subnets that need it (build agents, appliances) need a NAT gateway or firewall route.
* VNet-injected Azure Cache for Redis, which the Redis NSG supports, is a legacy model.
* Not checked from here: the Infoblox marketplace image offer, the Azure DevOps agent download URL and version, and the Microsoft package repository key used by the agent install script.
* WAF starts in Prevention for production. New applications usually need a period in Detection to tune false positives.
