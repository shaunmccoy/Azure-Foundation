# Terraform Modules

This repo contains modules, separated into providers, that form the reusable building blocks of cloud infrastructure. More information can be found in each module README, including a description of parameters and examples of usage.

## Usage

See the `examples` directory in each module for example usage. In your own Terraform code, you can directly reference the modules here without having to mirror them so long as there is an SSH key available that has pull access to this repo. If not, please contact us for help. For example:

```hcl
module "<module_name>" {
  source = "git::ssh://git@ssh.dev.azure.com:v3/example-org/PCET-SRE/terraform_modules/<provider>/<module_name>"
}
```

## Contributing

See `CONTRIBUTING.md` for more information.
