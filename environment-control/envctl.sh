#!/usr/bin/env bash
# envctl.sh: end-of-day cleanup for short-lived cloud resources.
#
# Every short-lived resource group (Azure), project (Google Cloud), or tagged
# resource (Amazon Web Services) carries four tags: lifetime=1d, owner, project,
# and created. created is a UTC time so something built a minute ago is not swept.
# This script finds everything marked lifetime=1d and deletes it. terraform destroy
# is still the normal teardown.
#
# Default is a dry run. Nothing is deleted unless you pass --apply.
#
#   ./envctl.sh                      dry run, Azure
#   ./envctl.sh --apply              delete for real, Azure
#   ./envctl.sh --cloud all          Azure, Google Cloud, and AWS
#   ./envctl.sh --cloud aws --apply  delete tagged AWS resources for real
#   ./envctl.sh --min-age 2          skip anything created less than 2 hours ago (default 1)
#   ./envctl.sh --check              only run the leftover check (no deleting at all)
#
# AWS has no resource group that deletes its children. --apply terminates
# instances, deletes volumes, removes NAT gateways, and releases addresses.
# Virtual networks stay until terraform destroy. Google Cloud deletes the
# project, which removes what is inside it. A label value cannot contain a
# colon, so a Google Cloud created label uses 2026-10-25t14-05-00z.
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
    -h|--help) sed -n '2,23p' "$0"; exit 0 ;;
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
import sys, datetime, re
from datetime import timezone
created, min_age = sys.argv[1], float(sys.argv[2])
if not created or created == "None":
    print("DELETE no created tag"); sys.exit()
# Google Cloud label values cannot contain a colon: 2026-10-25t14-05-00z
m = re.fullmatch(r"(\d{4}-\d{2}-\d{2})[tT](\d{2})-(\d{2})-(\d{2})[zZ]?", created.strip())
if m:
    created = "%sT%s:%s:%s" % m.groups()
try:
    c = created.strip().rstrip("Zz")
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
  local active
  active=$(gcloud auth list --filter="status:ACTIVE" --format="value(account)" 2>/dev/null || true)
  [ -n "$active" ] || { say "gcp: not signed in (run gcloud auth login), skipping"; return; }
  local json count
  json=$(gcloud projects list --filter="labels.lifetime=1d" --format=json 2>/dev/null || echo '[]')
  count=$(python3 -c 'import json,sys; print(len(json.load(sys.stdin)))' <<<"$json")
  say "gcp: $count project(s) labeled lifetime=1d"
  python3 -c 'import json,sys
for p in json.load(sys.stdin):
    labels=p.get("labels") or {}
    print(p.get("projectId","") + "\t" + (labels.get("created") or ""))' <<<"$json" |
  while IFS=$'\t' read -r name created; do
    [ -n "$name" ] || continue
    verdict=$(decide "$created")
    case "$verdict" in
      DELETE*)
        if $APPLY; then
          gcloud projects delete "$name" --quiet >/dev/null 2>&1 \
            && say "gcp: deleting project $name ($verdict)" \
            || say "gcp: could not delete project $name ($verdict)"
        else
          say "gcp: would delete project $name ($verdict)"
        fi ;;
      *) say "gcp: keeping project $name ($verdict)" ;;
    esac
  done
}

# Prints "kind<TAB>id". The account id inside an ARN is not printed.
aws_label() {
  python3 - "$1" <<'PY'
import sys
arn = sys.argv[1]
parts = arn.split(":")
tail = parts[5] if len(parts) > 5 else arn
if "/" in tail:
    kind, _, ident = tail.partition("/")
else:
    kind, ident = "resource", tail or arn
print("%s\t%s" % (kind or "resource", ident or arn))
PY
}

aws_delete() {
  local arn="$1" kind="$2" id="$3" region
  region=$(printf '%s' "$arn" | cut -d: -f4)
  [ -n "$region" ] || region=us-east-1
  case "$kind" in
    instance)
      if $APPLY; then
        aws ec2 terminate-instances --region "$region" --instance-ids "$id" >/dev/null 2>&1 \
          && say "aws: deleting instance $id" \
          || say "aws: could not delete instance $id"
      else
        say "aws: would delete instance $id"
      fi ;;
    volume)
      if $APPLY; then
        aws ec2 delete-volume --region "$region" --volume-id "$id" >/dev/null 2>&1 \
          && say "aws: deleting volume $id" \
          || say "aws: leaving volume $id (still attached or already gone)"
      else
        say "aws: would delete volume $id"
      fi ;;
    natgateway)
      if $APPLY; then
        aws ec2 delete-nat-gateway --region "$region" --nat-gateway-id "$id" >/dev/null 2>&1 \
          && say "aws: deleting nat gateway $id" \
          || say "aws: could not delete nat gateway $id"
      else
        say "aws: would delete nat gateway $id"
      fi ;;
    elastic-ip)
      if $APPLY; then
        aws ec2 release-address --region "$region" --allocation-id "$id" >/dev/null 2>&1 \
          && say "aws: releasing address $id" \
          || say "aws: could not release address $id"
      else
        say "aws: would release address $id"
      fi ;;
    *)
      say "aws: leaving $kind $id (terraform destroy removes the network)" ;;
  esac
}

aws_sweep() {
  command -v aws >/dev/null || { say "aws: aws cli not installed, skipping"; return; }
  aws sts get-caller-identity >/dev/null 2>&1 || { say "aws: not signed in, skipping"; return; }
  local regions region token page count kind id arn created verdict
  regions=$(aws ec2 describe-regions --region us-east-1 --query 'Regions[].RegionName' --output text 2>/dev/null || echo us-east-1)
  count=0
  for region in $regions; do
    token=""
    while true; do
      if [ -n "$token" ]; then
        page=$(aws resourcegroupstaggingapi get-resources --region "$region" --tag-filters Key=lifetime,Values=1d --starting-token "$token" --output json 2>/dev/null || echo '{}')
      else
        page=$(aws resourcegroupstaggingapi get-resources --region "$region" --tag-filters Key=lifetime,Values=1d --output json 2>/dev/null || echo '{}')
      fi
      token=""
      while IFS=$'\t' read -r arn created; do
        [ "$arn" = "TOKEN" ] && { token=$created; continue; }
        [ -n "$arn" ] || continue
        count=$((count + 1))
        verdict=$(decide "$created")
        kind=$(aws_label "$arn" | cut -f1)
        id=$(aws_label "$arn" | cut -f2)
        case "$verdict" in
          DELETE*) aws_delete "$arn" "$kind" "$id" ;;
          *) say "aws: keeping $kind $id ($verdict)" ;;
        esac
      done < <(python3 -c 'import json,sys
data=json.load(sys.stdin)
for item in data.get("ResourceTagMappingList") or []:
    created=""
    for tag in item.get("Tags") or []:
        if tag.get("Key")=="created":
            created=tag.get("Value") or ""
    print((item.get("ResourceARN") or "") + "\t" + created)
print("TOKEN\t" + (data.get("PaginationToken") or ""))' <<<"$page")
      [ -n "$token" ] || break
    done
  done
  say "aws: $count resource(s) tagged lifetime=1d"
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
