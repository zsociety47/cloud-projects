#!/usr/bin/env bash
# Offline test: a fake `az` stands in for Azure. Checks dry run, apply, min-age, missing tags.
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin"
OLD=$(date -u -d '30 hours ago' +%FT%TZ 2>/dev/null || date -u -v-30H +%FT%TZ)
NEW=$(date -u +%FT%TZ)
cat > "$T/bin/az" <<AZ
#!/usr/bin/env bash
echo "\$@" >> "$T/az.calls"
case "\$1 \$2" in
  "account show") exit 0 ;;
  "group list") echo '[{"name":"rg-old","created":"$OLD"},{"name":"rg-new","created":"$NEW"},{"name":"rg-nodate","created":null}]' ;;
  "group delete") exit 0 ;;
  "keyvault list-deleted") echo "kv-old" ;;
  "ad user") printf 'Junior Developer\tjunior-dev-zeon\nSomeone Else\tother\n' ;;
  "ad app") echo "sp-something-zeon01" ;;
  "policy assignment") echo "" ;;
  "consumption budget") echo "" ;;
esac
AZ
chmod +x "$T/bin/az"
export PATH="$T/bin:$PATH" ENVCTL_LOG_DIR="$T/log"
mkdir -p "$T/proj/p5"
echo '{"resources":[{"type":"x"},{"type":"y"}]}' > "$T/proj/p5/terraform.tfstate"
export ENVCTL_PROJECTS_DIR="$T/proj"

set +e; out=$("$HERE/envctl.sh"); code=$?; set -e
[ "$code" -eq 3 ] || { echo "FAIL expected exit 3 with leftovers, got $code"; exit 1; }
echo "$out" | grep -q "p5 state still lists 2 resource"  || { echo "FAIL state check"; exit 1; }
echo "$out" | grep -q "Entra user(s) still exist"      || { echo "FAIL entra user check"; exit 1; }
echo "$out" | grep -q "Entra app registration"          || { echo "FAIL entra app check"; exit 1; }
echo "$out" | grep -q "soft-deleted Key Vault"          || { echo "FAIL keyvault check"; exit 1; }
echo "$out" | grep -q "Someone Else" && { echo "FAIL flagged an unrelated user"; exit 1; }
echo "PASS leftover check warns and exits 3"
echo "$out" | grep -q "would delete rg-old"   || { echo "FAIL dry run old";  exit 1; }
echo "$out" | grep -q "keeping rg-new"        || { echo "FAIL min-age";      exit 1; }
echo "$out" | grep -q "would delete rg-nodate"|| { echo "FAIL no created";   exit 1; }
grep -q "group delete" "$T/az.calls" && { echo "FAIL dry run deleted something"; exit 1; }
echo "PASS dry run deletes nothing"

"$HERE/envctl.sh" --apply >/dev/null || true
grep -q "group delete --name rg-old --yes --no-wait"    "$T/az.calls" || { echo "FAIL apply old";    exit 1; }
grep -q "group delete --name rg-nodate --yes --no-wait" "$T/az.calls" || { echo "FAIL apply nodate"; exit 1; }
grep -q "group delete --name rg-new"                    "$T/az.calls" && { echo "FAIL deleted new group"; exit 1; }
echo "PASS apply deletes old and undated, keeps new"

rm -f "$T/proj/p5/terraform.tfstate"
cat > "$T/bin/az" <<'AZ2'
#!/usr/bin/env bash
case "$1 $2" in
  "account show") exit 0 ;;
  "group list") echo '[]' ;;
esac
AZ2
out=$("$HERE/envctl.sh" --check 2>&1); echo "$out" | grep -q "leftover check: clean" || { echo "FAIL clean run"; echo "$out"; exit 1; }
echo "PASS clean environment exits 0 and says clean"

# Google Cloud and AWS. The stand-in commands record calls and delete nothing real.
GCP_OLD=$(printf '%s' "$OLD" | tr 'T:' 't-' )
GCP_NEW=$(printf '%s' "$NEW" | tr 'T:' 't-' )
cat > "$T/bin/az" <<'AZ3'
#!/usr/bin/env bash
case "$1 $2" in
  "account show") exit 0 ;;
  "group list") echo '[]' ;;
esac
AZ3
cat > "$T/bin/aws" <<AWS
#!/usr/bin/env bash
echo "\$*" >> "$T/aws.calls"
case "\$1 \$2" in
  "sts get-caller-identity") exit 0 ;;
  "ec2 describe-regions") echo "us-east-1" ;;
  "resourcegroupstaggingapi get-resources") echo '{"ResourceTagMappingList":[
    {"ResourceARN":"arn:aws:ec2:us-east-1:111122223333:instance/i-old","Tags":[{"Key":"created","Value":"$OLD"}]},
    {"ResourceARN":"arn:aws:ec2:us-east-1:111122223333:instance/i-new","Tags":[{"Key":"created","Value":"$NEW"}]},
    {"ResourceARN":"arn:aws:ec2:us-east-1:111122223333:vpc/vpc-abc","Tags":[{"Key":"created","Value":"$OLD"}]}
  ]}' ;;
esac
exit 0
AWS
cat > "$T/bin/gcloud" <<GCLOUD
#!/usr/bin/env bash
echo "\$*" >> "$T/gcloud.calls"
case "\$1 \$2" in
  "auth list") echo "tester@example.com" ;;
  "projects list") echo '[{"projectId":"gcp-old","labels":{"lifetime":"1d","created":"$GCP_OLD"}},{"projectId":"gcp-new","labels":{"lifetime":"1d","created":"$GCP_NEW"}}]' ;;
esac
exit 0
GCLOUD
chmod +x "$T/bin/aws" "$T/bin/gcloud"
: > "$T/aws.calls"; : > "$T/gcloud.calls"
set +e; out=$("$HERE/envctl.sh" --cloud all); code=$?; set -e
echo "$out" | grep -q "would delete instance i-old" || { echo "FAIL aws dry run old"; echo "$out"; exit 1; }
echo "$out" | grep -q "keeping instance i-new" || { echo "FAIL aws min-age"; echo "$out"; exit 1; }
echo "$out" | grep -q "leaving vpc vpc-abc" || { echo "FAIL aws network kept"; echo "$out"; exit 1; }
echo "$out" | grep -q "111122223333" && { echo "FAIL printed an account id"; echo "$out"; exit 1; }
echo "$out" | grep -q "would delete project gcp-old" || { echo "FAIL gcp dry run old"; echo "$out"; exit 1; }
echo "$out" | grep -q "keeping project gcp-new" || { echo "FAIL gcp min-age"; echo "$out"; exit 1; }
grep -q "terminate-instances" "$T/aws.calls" && { echo "FAIL aws dry run deleted"; exit 1; }
grep -q "projects delete" "$T/gcloud.calls" && { echo "FAIL gcp dry run deleted"; exit 1; }
echo "PASS aws and gcp dry run deletes nothing"

: > "$T/aws.calls"; : > "$T/gcloud.calls"
"$HERE/envctl.sh" --cloud all --apply >/dev/null || true
grep -q "terminate-instances --region us-east-1 --instance-ids i-old" "$T/aws.calls" || { echo "FAIL aws apply old"; exit 1; }
grep -q "i-new" "$T/aws.calls" && { echo "FAIL aws deleted a new instance"; exit 1; }
grep -q "projects delete gcp-old --quiet" "$T/gcloud.calls" || { echo "FAIL gcp apply old"; exit 1; }
grep -q "projects delete gcp-new" "$T/gcloud.calls" && { echo "FAIL gcp deleted a new project"; exit 1; }
echo "PASS aws and gcp apply deletes old, keeps new and networks"
