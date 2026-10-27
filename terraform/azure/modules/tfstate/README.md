# tfstate

An Azure Terraform module. It lives at [`terraform/azure/modules/tfstate`](https://github.com/zsociety47/cloud-projects/tree/main/terraform/azure/modules/tfstate).

Creates the keep resource group and the storage account that holds one Terraform state blob per Azure project. Call it from `terraform/azure/pipeline-foundation` on the laptop. Shared keys are off.

Defaults: `rg-tfstate-zeon01`, `sttfstatezeon01`, container `tfstate`.
