# Scrub report

What was removed or replaced when this repository was rebuilt. No original value is repeated here.

## Credentials found in the original files: rotate these

They were committed in plain text, so treat them as exposed even though they are gone from this repository.

| What | Where it was |
| --- | --- |
| Azure DevOps personal access token | Top-level README |
| VPN pre-shared key | Default value of a variable in the VPN gateway module and in the hub config |
| ExpressRoute circuit authorization keys | All five hub variable files |
| Container registry admin password | Exposed as a Terraform output, so present in state and pipeline logs |
| Build agent token, VM admin password, SSH private key | Exposed as Terraform outputs in the build agent config |
| Storage account access key | Printed to the pipeline log by an `echo` in the pipeline templates |

## Identifiers replaced

| Kind | Replaced with |
| --- | --- |
| Client name and abbreviations in resource names, tags, image names, rule names | `org_code` variable (default `org`) and neutral names |
| Tag namespace | `<org_code>:` |
| Business unit names (seven spoke configs) | One `spoke` config with example units `BU1` and `API` |
| Internal environment name and its variants | `LAB` |
| Subscription, tenant and circuit IDs (over 30 distinct GUIDs) | `00000000-0000-0000-0000-0000000000NN` placeholders |
| Email addresses and domain | `example.com` |
| Azure DevOps organisation, project and pool names; external module source in that organisation | `example-org` placeholders; local `modules/linux_scaleset` |
| Network address plan (three /16 ranges) | `10.100.0.0/16` production, `10.101.0.0/16` DR, `10.102.0.0/16` non-production |
| On-premises proxy and DNS appliance addresses | Optional variables, documentation-range examples |
| VM names, admin user name, cost center | Generated names, `azadmin`, `0000` |
| Storage host names of test sites, state storage account name | Removed |
| A person's name in a code comment, placeholder web pages | Removed |
| Consultancy name in paths, remotes and a lab variable file | Removed |

## Not carried over

* The original Git history. It still contains every value above.
* macOS metadata files.

## How it was checked

A search of this repository for the client's names and abbreviations, every GUID from the
original files, the original secret strings, the original address ranges and the original
email domain returns no matches.
