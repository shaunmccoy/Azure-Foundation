# Azure DevOps Agent - Linux

This module will deploy a Linux VM for Azure DevOps Agents.

## Variables

See `variables.tf` for a description of values that can be provided to the module.

## Outputs

See `outputs.tf` for a list of resources and properties output by this module.

## Example

See the `examples` directory for example usage.

## Modules
Check `azure_devops_agent_linux/full` for more details on how to use this Linux module.

To apply only configurations, refer `azure_devops_agent_linux/config_only`

## Pipeline
`azure-devops-agnet-linux-pipelines.yml` is an example for setting up the pipeline yml

`vm_configuration.yml` is an example for setting up config only yml

## NOTE

Always copy `roles/azure_devops_agent` to the folder where ever you are running the vm_configuration