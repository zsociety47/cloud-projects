# GitHub to Azure pipeline foundation

Laptop-only root. It creates the shared Terraform state account and, when you add a project, that project's Entra app. It is not a numbered proof of concept. The demo of building this from scratch is [Terraform from GitHub to Azure](https://github.com/zsociety47/azure-terraform-pipeline-poc).

Do not run `terraform apply` from GitHub. Do not apply until you type the go-ahead in chat.

This folder is not a module. The modules it calls are in [`../modules/`](../modules/). The agent contract, copy-ready callers, and honest state live in the [parent README](../README.md).

## What it creates

Once:

- `rg-tfstate-zeon01` (`lifetime=keep`)
- `sttfstatezeon01` / container `tfstate`, shared keys off

Once per entry in `projects`:

- Entra app `github-actions-<repository-name>`
- Federated credentials `github-pull-request` and `github-main`
- Reader on the state group, Storage Blob Data Contributor on the account, Contributor on that project's group

## First apply (laptop)

```bash
export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
terraform init
terraform plan
# wait for approval, then:
# terraform apply
```

State starts local. After the account exists:

```bash
# add backend.tf pointing at sttfstatezeon01, key pipeline-foundation.tfstate
terraform init -migrate-state
```

## Add a later project (cost dashboard, backup)

Follow the checklist in the [parent README](../README.md). Copy the caller workflows from [`../examples/`](../examples/). Do not set `environment:` on those callers.

## Destroy

Destroy a project's Entra app by removing its `projects` entry and applying, or by destroying that module instance. Do not destroy `rg-tfstate-zeon01` while any project still uses the blobs. The nightly sweep leaves `lifetime=keep` groups alone.
