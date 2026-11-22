## Requirements

Need a Resource group, and subnet for provisioning of the scaleset.

At the moment only takes a gallery img with optional plan info.

## Providers

| Name | Version |
|------|---------|
| azurerm | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_username | Admin username | `string` | `"azdoagent"` | no |
| cloud\_init | Init data for VM | `string` | n/a | yes |
| diff\_disk | n/a | `string` | `"Local"` | no |
| identity\_ids | List of user managed identity ids to assign | `list(string)` | `[]` | no |
| identity\_type | Whether identity type is either SystemAssigned or UserAssigned | `string` | `"SystemAssigned"` | no |
| image\_id | ID of img to use | `string` | n/a | yes |
| lb\_backend\_pool\_ids | Specifies an array of references to backend address pools of load balancers | `list(string)` | `[]` | no |
| managed\_disk\_type | Default disk type | `string` | `"Standard_LRS"` | no |
| name | Name for the scale set | `string` | n/a | yes |
| os\_cache | The type of Caching which should be used for this Data Disk. Possible values are None, ReadOnly and ReadWrite | `string` | `"ReadOnly"` | no |
| os\_disk\_gb | n/a | `number` | `30` | no |
| overprovision | Disable overprovisioning, Azure DevOps will manage this | `bool` | `false` | no |
| plan | OS plan source | `map(string)` | `{}` | no |
| rg\_name | Name of resource group to be added to | `string` | n/a | yes |
| sku\_name | Size of VMs | `string` | `"Standard_D2s_v3"` | no |
| ssh\_key | SSH public key data | `string` | `null` | no |
| subnet\_id | ID of subnet to use | `string` | n/a | yes |
| tags | A mapping of tags to assign to the resource. | `map(string)` | n/a | yes |
| upgrade\_mode | Method for updating VMs in scaleset | `string` | `"Manual"` | no |
| vm\_count | Default vm count for scaleset | `number` | `2` | no |
| write\_accelerator\_enabled | Should Write Accelerator be enabled for this Data Disk? | `bool` | `false` | no |
| zone\_balance | Balance VMs across zones | `bool` | `true` | no |
| zones | Number of zones to spread out VMs. Options are 1, 2, 3 | `list(string)` | <pre>[<br>  "1",<br>  "2"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| scale\_id | ID of the scaleset |