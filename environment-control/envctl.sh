#!/usr/bin/env bash
# envctl.sh: end-of-day cleanup for lab resources (the "environment control" rule).
#
# Every lab resource group (Azure), project (GCP), or tagged resource (AWS) carries the same
# three tags: lifetime=1d, owner=<you>, project=<repo>. Plus created=<UTC time> so a group
# built a minute ago is not swept. This script finds everything marked lifetime=1d and
# deletes it. It is the safety net; `terraform destroy` is still the normal teardown.
#
# Default is a DRY RUN. Nothing is deleted unless you pass --apply.
#
#   ./envctl.sh                      dry run, Azure
#   ./envctl.sh --apply              delete for real, Azure
#   ./envctl.sh --cloud all          include GCP and AWS (report only for now)
#   ./envctl.sh --min-age 2          skip anything created less than 2 hours ago (default 1)
#
# Never prints subscription ids, account ids, or sign-in names.
set -euo pipefail

APPLY=false
CLOUD=azure
MIN_AGE_HOURS=1
LOG_DIR="${ENVCTL_LOG_DIR:-$HOME/.environment-control}"
LOG="$LOG_DIR/envctl.log"
mkdir -p "$LOG_DIR"

while [ $# -gt 0 ]; do
  case "$1" in
    --apply) APPLY=true ;;
    --cloud) CLOUD="${2:?azure, gcp, aws, or all}"; shift ;;
    --min-age) MIN_AGE_HOURS="${2:?hours}"; shift ;;
    -h|--help) sed -n 2,19p "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

say() { printf '%s\n' "$*"; printf '%s %s\n' "$(date -u +%FT%TZ)" "$*" >> "$LOG"; }
MODE=$($APPLY && echo APPLY || echo "DRY RUN")
say "envctl start: cloud=$CLOUD mode=$MODE min-age=${MIN_AGE_HOURS}h"

# Decide per item: prints "DELETE" or "SKIP <reason>" from a name and a created tag.
decide() {
  python3 - "$1" "$MIN_AGE_HOURS" <<'PY'
import sys, datetime
from datetime import timezone
created, min_age = sys.argv[1], float(sys.argv[2])
if not created:
    print("DELETE no created tag"); sys.exit()
try:
    c = created.rstrip("Z")
    t = datetime.datetime.fromisoformat(c if "T" in c else c + "T00:00:00")
except ValueError:
    print("DELETE unreadable created tag"); sys.exit()
age = (datetime.datetime.now(timezone.utc).replace(tzinfo=None) - t).total_seconds() / 3600
print("SKIP younger than %.1fh (age %.1fh)" % (min_age, age) if age < min_age else "DELETE age %.1fh" % age)
PY
}

azure_sweep() {
  command -v az >/dev/null || { say "azure: az not installed, skipping"; return; }
  az account show >/dev/null 2>&1 || { say "azure: not signed in (run az login), skipping"; return; }
  local json
  json=$(az group list --tag lifetime=1d --query "[].{name:name, created:tags.created}" -o json)
  local count; count=$(python3 -c 'import json,sys; print(len(json.load(sys.stdin)))' <<<"$json")
  say "azure: $count resource group(s) tagged lifetime=1d"
  python3 -c 'import json,sys
for g in json.load(sys.stdin): print(g["name"] + "\t" + (g.get("created") or ""))' <<<"$json" |
  while IFS=$'\t' read -r name created; do
    verdict=$(decide "$created")
    case "$verdict" in
      DELETE*)
        if $APPLY; then
          az group delete --name "$name" --yes --no-wait
          say "azure: deleting $name ($verdict)"
        else
          say "azure: would delete $name ($verdict)"
        fi ;;
      *) say "azure: keeping $name ($verdict)" ;;
    esac
  done
  # Things a resource group delete does NOT clean up. Report, never auto-delete.
  local deleted
  deleted=$(az keyvault list-deleted --query "[].name" -o tsv 2>/dev/null || true)
  [ -n "$deleted" ] && say "azure: soft-deleted Key Vaults still reserve their names (purge by hand if you need the name back): $(echo "$deleted" | tr '\n' ' ')"
  say "azure: not covered by a group delete: Entra users and app registrations, subscription-level policies and budgets. Use terraform destroy for those."
}

gcp_sweep() {
  command -v gcloud >/dev/null || { say "gcp: gcloud not installed, skipping"; return; }
  say "gcp: projects labeled lifetime=1d (report only until the GCP round):"
  gcloud projects list --filter="labels.lifetime=1d" --format="value(projectId,labels.created)" 2>/dev/null | while read -r p c; do say "gcp: would delete project $p (created ${c:-unknown})"; done
}

aws_sweep() {
  command -v aws >/dev/null || { say "aws: aws cli not installed, skipping"; return; }
  say "aws: resources tagged lifetime=1d (report only until the AWS round):"
  aws resourcegroupstaggingapi get-resources --tag-filters Key=lifetime,Values=1d --query "ResourceTagMappingList[].ResourceARN" --output text 2>/dev/null | tr '\t' '\n' | while read -r arn; do [ -n "$arn" ] && say "aws: tagged $arn"; done
}

case "$CLOUD" in
  azure) azure_sweep ;;
  gcp) gcp_sweep ;;
  aws) aws_sweep ;;
  all) azure_sweep; gcp_sweep; aws_sweep ;;
  *) echo "Unknown cloud: $CLOUD" >&2; exit 2 ;;
esac
say "envctl done"
