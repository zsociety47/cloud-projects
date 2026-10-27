# Copy-ready files for a later Azure project

Azure only. These are not modules. Copy them into the later Azure project's repository after the shared state account exists. Change only the blob `key` in `backend.tf`.

| File | Copy to | What it does |
|---|---|---|
| [`plan.yml`](plan.yml) | `.github/workflows/plan.yml` | On a pull request, calls the Azure reusable plan job |
| [`apply.yml`](apply.yml) | `.github/workflows/apply.yml` | On a push to `main`, calls the Azure reusable apply job |
| [`backend.tf.example`](backend.tf.example) | `backend.tf` | Points Terraform state at `sttfstatezeon01`, one blob per project |

The jobs they call live in [`.github/workflows/`](../../../.github/workflows/), not in this folder. Those files are named `azure-terraform-plan.yml` and `azure-terraform-apply.yml`.

Do not set `environment:` on the copied workflows. That would change the OpenID Connect (OIDC) subject and Azure would refuse the sign-in.
