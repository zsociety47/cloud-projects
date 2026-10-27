# Terraform modules

This folder is the modules. Later Azure projects call these. They do not copy [Terraform from GitHub to Azure](https://github.com/zsociety47/azure-terraform-pipeline-poc).

A Terraform module is a folder of `.tf` files another root can reuse. The laptop root that calls them is [`../pipeline-foundation/`](../pipeline-foundation/).

| Folder | What it creates | Call it from |
|---|---|---|
| [`azure-tfstate/`](azure-tfstate/) | The keep resource group `rg-tfstate-zeon01` and the state storage account `sttfstatezeon01` | `pipeline-foundation`, once |
| [`azure-github-oidc/`](azure-github-oidc/) | One Microsoft Entra app per GitHub repository, two federated credentials, Reader on the state group, blob contributor on the state account, Contributor on that project's group | `pipeline-foundation`, once per project |

Exact GitHub paths:

- https://github.com/zsociety47/cloud-projects/tree/main/terraform/modules
- https://github.com/zsociety47/cloud-projects/tree/main/terraform/modules/azure-tfstate
- https://github.com/zsociety47/cloud-projects/tree/main/terraform/modules/azure-github-oidc

Do not apply a module by itself. Apply `pipeline-foundation` on the laptop after Zeon types the go-ahead. Nothing here has been applied yet.

Numeric GitHub ids for OpenID Connect (OIDC) come from [`azure-github-oidc/scripts/oidc-ids.sh`](azure-github-oidc/scripts/oidc-ids.sh).
