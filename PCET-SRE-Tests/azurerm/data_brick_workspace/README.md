# Data Brick Workspace Module Test


## Prerequisites

The following configurations need to have been run before this configuration will work
* none

## LAB Local run commands

Terraform init command must be run first.
* The Azure console can provdie the access key that's scrubbed here.
* Local Terraform initialization files are suppressed from source control by design.

```
terraform init -backend-config="storage_account_name=exampleappmigterraformstate" -backend-config="access_key=SCRUBBED" -backend-config="container_name=tfstate" -backend-config="key=data-brick-workspace.terraform.tfstate"

terraform plan -var-file environments/lab.tfvars
terraform apply -var-file environments/lab.tfvars
terraform destroy -var-file environments/lab.tfvars
```