# Azure Terraform

Azure only. Google Cloud lives in [`../gcp/`](../gcp/). Amazon Web Services lives in [`../aws/`](../aws/).

This is the shared GitHub-to-Azure pipeline later Azure projects call. The walkthrough of building that pipeline by hand is [Terraform from GitHub to Azure](https://github.com/zsociety47/azure-terraform-pipeline-poc). Do not copy that repository.

**The modules are in [`modules/`](modules/).** That is the folder to open first.

```text
terraform/azure/
├── modules/                 the Azure modules (call these)
│   ├── tfstate/             keep resource group and state storage account
│   └── github-oidc/         one Microsoft Entra app per GitHub repository
├── pipeline-foundation/     laptop root that applies the modules
├── examples/                copy into a later Azure project's repo
└── README.md                this file
```

Exact GitHub path for the Azure modules: https://github.com/zsociety47/cloud-projects/tree/main/terraform/azure/modules

| Folder | What it is | Apply from |
|---|---|---|
| [`modules/tfstate/`](modules/tfstate/) | Keep resource group and state storage account | `pipeline-foundation` on the laptop, once |
| [`modules/github-oidc/`](modules/github-oidc/) | One Entra app, two federated credentials, Reader on the state group, blob contributor on the state account, Contributor on that project's group | `pipeline-foundation` on the laptop, once per project |
| [`pipeline-foundation/`](pipeline-foundation/) | The root that calls the two modules. `projects = {}` until a later project is ready | the laptop, never GitHub |
| [`examples/`](examples/) | Caller workflows and a `backend.tf` stub | copy into the later Azure project's repo |

Reusable GitHub Actions jobs for Azure: [`azure-terraform-plan.yml`](../../.github/workflows/azure-terraform-plan.yml) and [`azure-terraform-apply.yml`](../../.github/workflows/azure-terraform-apply.yml). A project workflow calls them. It does not copy the job.

Do not apply these modules from GitHub. The runner cannot create the Entra app it uses to sign in.

## Run this as yourself

The defaults (`rg-tfstate-zeon01`, `sttfstatezeon01`, `owner = zeon`) are this proof of concept. Copy `pipeline-foundation/terraform.tfvars.example` to `terraform.tfvars` and put your owner word in the names. Storage account names are lowercase letters and digits only, and they must be unique across Azure. After the first apply, write `backend.tf` with those same names. Do not copy the `zsociety47` GitHub ids from the example `projects` map. Get yours with `modules/github-oidc/scripts/oidc-ids.sh owner/name`.

The reusable jobs at `zsociety47/cloud-projects/.github/workflows/azure-terraform-*.yml` are public. You can call them from your repository, or fork this repository and point `uses:` at your fork.

## Honest state

Applied Oct 26, 2026 from the laptop. `rg-tfstate-zeon01` (`lifetime=keep`) and `sttfstatezeon01` / container `tfstate` exist. State blob is `pipeline-foundation.tfstate`. `projects = {}`, so no Entra apps yet. A follow-up plan was no changes. Do not recreate Project 7's groups.

Project 6 (AWS to Azure migrate) stays off this pipeline.

## For later Azure project agents

Read this file before writing Terraform. The modules you call are in [`modules/`](modules/). Do not copy Project 7's workflows. Do not share Project 7's Entra app. One Microsoft Entra app per GitHub repository.

Azure 8 (cost dashboard) calls these modules. Locked group: `rg-cost-poc-zeon01`. State blob key: `cost-dashboard.tfstate`.

Azure 9 (backup) calls these modules the same way. Locked group: `rg-backup-poc-zeon01`. State blob key: `backup-system.tfstate`. The backup resources stay in that repo. They are not extracted into a module on this pass.

When a project that should call this pipeline has a resource group and a GitHub remote:

1. Create the project's resource group on the laptop. GitHub cannot create groups.
2. Create the GitHub repository, then run `modules/github-oidc/scripts/oidc-ids.sh owner/name`.
3. Add a `projects` entry in `pipeline-foundation/terraform.tfvars` (see `terraform.tfvars.example`). Use the resource group name that project already locked.
4. Stop. Do not apply `pipeline-foundation` until Zeon types the go-ahead in chat.
5. After that apply, pipe `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID` into that repo's secrets. Each project has its own client id. Do not print the values.
6. Copy `examples/backend.tf.example` into that repo as `backend.tf`. Change only the blob `key`.
7. Copy `examples/plan.yml` and `examples/apply.yml` into that repo's `.github/workflows/`. Do not set `environment:` on those callers.

Leave Project 6 alone. Leave Project 7's recording path alone.

## First laptop apply of the foundation

Wait for approval. Then, from `pipeline-foundation`:

```bash
export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
terraform init
terraform plan
# wait for approval, then:
# terraform apply
```

State starts local. After the account exists, add `backend.tf` pointing at `sttfstatezeon01`, key `pipeline-foundation.tfstate`, and run `terraform init -migrate-state`.
