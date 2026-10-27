# Daily push checklist

Nothing counts as saved until it is on GitHub. Run this at the start and the end of every Cursor session, and fix anything that fails before new work.

## Start of session: is the Mac stale?

In each repo below, run `git fetch` and `git status -sb`. If it says `behind`, run `git pull` first. If it says `ahead`, those commits were never pushed: push them before anything else.

## The repos

The folder is `~/Desktop/cloud-portfolio`. Project repos live in `azure/`, `gcp/`, or `aws/`. `cloud-projects` and `loom-notes` stay at the top.

| Repo | What lives there |
|---|---|
| cloud-projects | standards, environment-control, roadmap, terraform/azure/modules |
| loom-notes | plans, lessons, concepts, LinkedIn drafts, video scripts |
| 01-azure-static-website-poc | the public tracker site (progress.json) |
| gcp/01-gcp-static-website-poc | static website on Cloud Storage |
| gcp/02-gcp-two-tier-network-poc | two-tier network, in progress |
| aws/01-aws-static-website-poc | static website on CloudFront |
| 02 to 05 azure poc repos | finished projects |
| 07-azure-terraform-pipeline-poc | in progress |
| 06-aws-to-azure-migrate-poc | in progress |
| 08-azure-cost-dashboard | cost visibility dashboard, in progress |
| 09-azure-backup-system | backup system, in progress |
| any new repo | create it from `setup-handoff.sh` and add it to this table |

## End of session

1. `git status` in each repo. Commit anything real (never `.env`, state files, keys, or subscription ids).
2. `git push` in each repo. If it fails, fix it, do not skip it.
3. Update the tracker (`scripts/mark-done.sh`) and push the tracker repo, so the public page matches.
4. Run `./envctl.sh --check` in cloud-projects/environment-control. Nothing should be left running.
5. Update `.handoff/HANDOFF.md` in the repos touched.

## Friday office day adds

Weekly summary from Claude, one hour on lab guides, and a push of every repo even if nothing changed.
