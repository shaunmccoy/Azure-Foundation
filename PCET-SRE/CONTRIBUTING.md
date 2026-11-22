# Contributing

Each module should, at a minimum,   contain;

- `./main.tf` - contains the resources that this module creates.
- `./variables.tf` - contains the values that can be provided to the module. Variables will likely be directly correlated to parameters provided to resources, so they can and should share a name unless there is a reason not to. In these cases the description of the parameter from the Terraform documentation can be directly copied as a description of the variable.
- `./outputs.tf` - contains `output` blocks that expose the properties of the resources that were created so they can either be viewed or passed through to other modules.
- `./README.md` - provides an overview of what the module does and how to use it.
- `./examples/*.tf` - contains example Terraform code that uses the module and describes one or more use cases. These examples should be completely standalone (if a resource needs a resource group, for example, a resource group should be randomly named at runtime and created and destroyed as part of the example). These examples are also used for local development and automated testing of one or more use cases of the module.
