# Environment control

The rule: every lab resource is deleted at the end of the day it was made. This folder is the safety net that enforces it. `terraform destroy` stays the normal teardown; `envctl.sh` catches whatever was left behind.

## Quick start (run these on your Mac)

Open the Terminal app on your Mac, not Claude and not Cursor's chat. Cursor's built-in terminal also works. Every command below is run from this folder:

```bash
cd ~/Desktop/azure-mentorship/cloud-projects/environment-control
```

Do this once, before you build project 7:

1. `az login` (sign in to Azure in the browser, then close the tab).
2. `./envctl.sh` is a dry run. It lists what it would delete and deletes nothing. Read the list.
3. `./envctl.sh --check` runs only the leftover check. Run it now and after each project. Project 5's Entra test user may still show up as a warning. If it does, run `terraform destroy` in that project folder.
4. `./install-launchd.sh` turns on the nightly 11:30 PM delete. Run it once. `./install-launchd.sh --remove` turns it off.
5. If a command says "permission denied", run `chmod +x envctl.sh install-launchd.sh test/test-envctl.sh` once.

Every day after that, the only habit is: tag each new resource group with the four tags, finish with `terraform destroy`, and read any `WARNING` in `~/.environment-control/envctl.log`.

To confirm the script itself works without touching Azure, run `./test/test-envctl.sh`. It uses a fake Azure command.

## The tag contract (same on every cloud)

| Tag | Value | Why |
|---|---|---|
| `lifetime` | `1d` | The consent to delete. Only groups with this exact tag are ever touched. |
| `owner` | your name | Who made it. |
| `project` | the repo name | What it belongs to. |
| `created` | UTC time, `2026-10-23T14:05:00Z` | Lets the sweep skip anything made in the last hour. A missing `created` counts as old. |

Azure resource groups use tags. Google Cloud projects use labels (lowercase keys and values). AWS uses tags on each resource. The names and values are the same on all three.

Anything you want to keep: do not tag it `lifetime=1d`. Use `lifetime=keep`. The sweep ignores it.

## Terraform snippet

```hcl
variable "owner" { type = string }

resource "azurerm_resource_group" "main" {
  name     = "rg-example-zeon01"
  location = "eastus"
  tags = {
    lifetime = "1d"
    owner    = var.owner
    project  = "azure-example-poc"
    created  = formatdate("YYYY-MM-DD'T'hh:mm:ss'Z'", timestamp())
  }
  lifecycle {
    ignore_changes = [tags["created"]]  # timestamp() changes every plan; this keeps the plan clean
  }
}
```

For a group made with the Azure CLI: `az group create ... --tags lifetime=1d owner=zeon project=<repo> created=$(date -u +%FT%TZ)`.

## Use

```bash
./envctl.sh                 # dry run, Azure: lists what it would delete, deletes nothing
./envctl-aws.sh             # dry run, Amazon Web Services only
./envctl-gcp.sh             # dry run, Google Cloud only
./envctl.sh --apply         # deletes for real, Azure
./envctl.sh --min-age 2     # skip groups younger than 2 hours (default 1)
./envctl.sh --cloud all     # Azure, Google Cloud, and AWS. Add --apply to delete.
```

`envctl-aws.sh` and `envctl-gcp.sh` accept `--apply` and `--min-age`. They do not accept `--cloud`. A dry run is the way to check them.

Log: `~/.environment-control/envctl.log`. Nothing it prints contains a subscription id, account id, or sign-in name.

## Nightly run on the Mac

```bash
./install-launchd.sh            # 11:30 PM every night, all three clouds, --apply
./install-launchd.sh --remove
```

Run these on the Mac itself, not from Claude's cloud session (it cannot reach macOS launchd or the Azure CLI). If the Mac is asleep at 11:30 PM, the job runs when it wakes. You must be signed in (`az login`); if you are not, the run logs that and deletes nothing.

## What it does not clean up, and the check that watches for it

Deleting a resource group does not remove Entra users and app registrations, subscription-level policies and budgets, or the reserved names of soft-deleted Key Vaults. Only `terraform destroy` removes the first three.

Every run ends with a leftover check, and `./envctl.sh --check` runs only that. It looks for:

- Terraform state that still lists resources (the sign that `terraform destroy` was not run), under `ENVCTL_PROJECTS_DIR` (default `~/Desktop/azure-mentorship`)
- Entra users and app registrations whose names match `ENVCTL_ENTRA_MATCH` (default `zeon01|junior-dev`)
- Policy assignments and budgets with `zeon01` in the name
- Soft-deleted Key Vaults

If anything is found it prints `WARNING` lines, shows a macOS notification, and exits with code 3, so the nightly log shows it. A clean run says `leftover check: clean` and exits 0.

## Status by cloud

| Cloud | Status |
|---|---|
| Azure | Deletes resource groups tagged `lifetime=1d`. |
| Google Cloud | Deletes projects labeled `lifetime=1d`. A `created` label cannot contain a colon, so write it as `2026-10-25t14-05-00z`. |
| Amazon Web Services | Terminates instances, deletes volumes, removes NAT gateways, and releases addresses tagged `lifetime=1d`. Virtual networks stay until `terraform destroy`. |

A dry run is still the default. `--apply` is what deletes. The nightly job uses `--cloud all` only after you run `./install-launchd.sh` again. An agent installed earlier still cleans Azure only.

## Test

`./test/test-envctl.sh` runs offline with a fake `az`. It proves a dry run deletes nothing, an apply deletes old and undated groups, and a group made a minute ago is kept.
