# Reusable Plan and Apply jobs, grouped by cloud

GitHub only loads files in this directory. Grouping is the filename prefix: `azure-`, later `gcp-` and `aws-`.

| File | Cloud |
|---|---|
| [`azure-terraform-plan.yml`](azure-terraform-plan.yml) | Azure. Pull requests plan. They do not apply |
| [`azure-terraform-apply.yml`](azure-terraform-apply.yml) | Azure. Pushes to `main` apply |

What they are and the exact GitHub paths are in [`.github/README.md`](../README.md). Copy-ready Azure callers are in [`terraform/azure/examples/`](../../terraform/azure/examples/).
