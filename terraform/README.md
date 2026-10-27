# Terraform modules

Shared building blocks for Azure projects after [Terraform from GitHub to Azure](https://github.com/zsociety47/azure-terraform-pipeline-poc). That repository stays the demo of building the pipeline from scratch. These modules are the foundation later projects call.

Do not copy `azure-terraform-pipeline-poc`. Call this folder.

| Folder | Apply from | What it creates |
|---|---|---|
| `azure-tfstate` | `pipeline-foundation` on the laptop, once | The keep resource group and the state storage account |
| `azure-github-oidc` | `pipeline-foundation` on the laptop, once per project | One Entra app, two federated credentials, Reader on the state group, blob contributor on the state account, Contributor on that project's group |
| `pipeline-foundation` | the laptop, never GitHub | The root that calls the two modules. `projects = {}` until a later project is ready |
| `examples/` | copy into the later project's repo | Caller workflows and a `backend.tf` stub |

Reusable GitHub Actions jobs live in [`.github/workflows/terraform-plan.yml`](../.github/workflows/terraform-plan.yml) and [`terraform-apply.yml`](../.github/workflows/terraform-apply.yml). A project workflow calls them. It does not copy the job.

Do not apply these modules from GitHub. The runner cannot create the Entra app it uses to sign in.

## Honest state

Nothing in this folder has been applied. `rg-tfstate-zeon01` and `sttfstatezeon01` do not exist yet. `pipeline-foundation` has `projects = {}`. Project 7 proved the pattern (plan on a pull request, apply on `main`, numeric OpenID Connect subjects, Reader then Contributor). This is that pattern extracted. Do not recreate Project 7's groups.

Project 6 (AWS to Azure migrate) stays off this pipeline.

## For Azure 8 and 9 agents

Read this file before writing Terraform. Do not copy Project 7's workflows. Do not share Project 7's Entra app. One Microsoft Entra app per GitHub repository.

When that project has a resource group and a GitHub remote:

1. Create the project's resource group on the laptop. GitHub cannot create groups.
2. Create the GitHub repository, then run `azure-github-oidc/scripts/oidc-ids.sh owner/name`.
3. Add a `projects` entry in `pipeline-foundation/terraform.tfvars` (see `terraform.tfvars.example`). Use the resource group name that project already locked. Azure 9 locked `rg-backup-poc-zeon01`. Azure 8 has not locked a group name yet.
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
