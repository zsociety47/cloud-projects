# Reusable GitHub Actions jobs

These workflows do not run when this repository is pushed. They are `workflow_call` jobs. A later project's own `plan.yml` and `apply.yml` call them.

GitHub Actions is the robot that runs the Terraform files on GitHub. Terraform is the tool that builds cloud from text files.

| File | When a caller starts it | What it does |
|---|---|---|
| [`workflows/terraform-plan.yml`](workflows/terraform-plan.yml) | Pull request | Format, init, validate, plan, comment, optional verify. Does not apply |
| [`workflows/terraform-apply.yml`](workflows/terraform-apply.yml) | Push to `main` | Format, init, validate, apply, optional verify |

Copy-ready callers are in [`../terraform/examples/`](../terraform/examples/).

Do not set a GitHub `environment:` key on the caller. That would change the OpenID Connect (OIDC) subject and Azure would refuse the sign-in.

Exact GitHub paths:

- https://github.com/zsociety47/cloud-projects/blob/main/.github/workflows/terraform-plan.yml
- https://github.com/zsociety47/cloud-projects/blob/main/.github/workflows/terraform-apply.yml
