# Reusable GitHub Actions jobs

Grouped by cloud in the filename. GitHub only loads workflow files that sit directly in `.github/workflows/`, so there is no `azure/` subfolder here.

These workflows do not run when this repository is pushed. They are `workflow_call` jobs. A later project's own `plan.yml` and `apply.yml` call them.

| File | Cloud | When a caller starts it | What it does |
|---|---|---|---|
| [`workflows/azure-terraform-plan.yml`](workflows/azure-terraform-plan.yml) | Azure | Pull request | Format, init, validate, plan, comment, optional verify. Does not apply |
| [`workflows/azure-terraform-apply.yml`](workflows/azure-terraform-apply.yml) | Azure | Push to `main` | Format, init, validate, apply, optional verify |

Google Cloud and AWS jobs are not here yet. When they exist they will be `gcp-terraform-*.yml` and `aws-terraform-*.yml`.

Copy-ready Azure callers are in [`../terraform/azure/examples/`](../terraform/azure/examples/).

Do not set a GitHub `environment:` key on an Azure caller. That would change the OpenID Connect (OIDC) subject and Azure would refuse the sign-in.

Exact GitHub paths:

- https://github.com/zsociety47/cloud-projects/blob/main/.github/workflows/azure-terraform-plan.yml
- https://github.com/zsociety47/cloud-projects/blob/main/.github/workflows/azure-terraform-apply.yml
