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
#   ./envctl.sh --check              only run the leftover check (no deleting at all)
#
# A resource group delete does NOT remove Entra users and app registrations, subscription-level
# policy and budgets, or soft-deleted Key Vault names. After every run the script checks for
# those, and for any Terraform state that still lists resources (meaning terraform destroy was
# not run). If it finds any, it prints a WARNING, shows a macOS notification, and exits 3.
# Settings: ENVCTL_PROJECTS_DIR (where to look for terraform.tfstate, default
# ~/Desktop/azure-mentorship), ENVCTL_ENTRA_MATCH (names to flag, default 'zeon01|junior-dev').
#
# Never prints subscription ids, account ids, or sign-in names.
set -euo pipefail

APPLY=false
CLOUD=azure
MIN_AGE_HOURS=1
CHECK_ONLY=false
PROJECTS_DIR="${ENVCTL_PROJECTS_DIR:-$HOME/Desktop/azure-mentorship}"
ENTRA_MATCH="${ENVCTL_ENTRA_MATCH:-zeon01|junior-dev}"
LEFTOVERS=0
LOG_DIR="${ENVCTL_LOG_DIR:-$HOME/.environment-control}"
LOG="$LOG_DIR/envctl.log"
mkdir -p "$LOG_DIR"

while [ $# -gt 0 ]; do
  case "$1" in
    --apply) APPLY=true ;;
    --cloud) CLOUD="${2:?azure, gcp, aws, or all}"; shift ;;
    --min-age) MIN_AGE_HOURS="${2:?hours}"; shift ;;
    --check) CHECK_ONLY=true ;;
    -h|--help) sed -n 2,28p "$0"; exit 0 ;;
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

warn() { say "WARNING: $*"; LEFTOVERS=1; }

leftover_check() {
  say "leftover check: things a resource group delete does not remove"
  # 1. Terraform state that still lists resources: terraform destroy was not run there.
  if [ -d "$PROJECTS_DIR" ]; then
    while IFS= read -r f; do
      n=$(python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1])).get("resources",[])))' "$f" 2>/dev/null || echo 0)
      [ "${n:-0}" -gt 0 ] && warn "$(basename "$(dirname "$f")") state still lists $n resource(s). Run terraform destroy there so state and Azure agree."
    done < <(find "$PROJECTS_DIR" -maxdepth 3 -name terraform.tfstate -not -path '*/.terraform/*' 2>/dev/null)
  else
    say "leftover check: $PROJECTS_DIR not found, skipped the Terraform state scan"
  fi
  # 2. Azure objects outside resource groups (only if signed in).
  if command -v az >/dev/null && az account show >/dev/null 2>&1; then
    local users apps pols buds kvs
    users=$(az ad user list --query "[].{n:displayName,m:mailNickname}" -o tsv 2>/dev/null | grep -Ei "$ENTRA_MATCH" || true)
    [ -n "$users" ] && warn "Entra user(s) still exist: $(echo "$users" | awk '{print $1" "$2}' | tr '\n' ';'). terraform destroy removes them; a group delete does not."
    apps=$(az ad app list --all --query "[].displayName" -o tsv 2>/dev/null | grep -Ei "$ENTRA_MATCH" || true)
    [ -n "$apps" ] && warn "Entra app registration(s) still exist: $(echo "$apps" | tr '\n' ';')"
    pols=$(az policy assignment list --query "[?contains(name,'zeon01')].name" -o tsv 2>/dev/null || true)
    [ -n "$pols" ] && warn "subscription-level policy assignment(s) still exist: $(echo "$pols" | tr '\n' ' ')"
    buds=$(az consumption budget list --query "[?contains(name,'zeon01')].name" -o tsv 2>/dev/null || true)
    [ -n "$buds" ] && warn "subscription-level budget(s) still exist: $(echo "$buds" | tr '\n' ' ')"
    kvs=$(az keyvault list-deleted --query "[].name" -o tsv 2>/dev/null || true)
    [ -n "$kvs" ] && warn "soft-deleted Key Vault(s) still reserve their names (purge by hand if you need the name back): $(echo "$kvs" | tr '\n' ' ')"
  else
    say "leftover check: not signed in to Azure, skipped the Entra, policy, budget, and Key Vault checks"
  fi
  if [ "$LEFTOVERS" -eq 0 ]; then
    say "leftover check: clean"
  else
    say "WARNING: leftovers found. A resource group delete does not clean these up. See the lines above."
    command -v osascript >/dev/null && osascript -e 'display notification "Leftover cloud resources found. See ~/.environment-control/envctl.log" with title "envctl"' || true
  fi
}

if ! $CHECK_ONLY; then
  case "$CLOUD" in
    azure) azure_sweep ;;
    gcp) gcp_sweep ;;
    aws) aws_sweep ;;
    all) azure_sweep; gcp_sweep; aws_sweep ;;
    *) echo "Unknown cloud: $CLOUD" >&2; exit 2 ;;
  esac
fi
leftover_check
say "envctl done"
[ "$LEFTOVERS" -eq 0 ] || exit 3
