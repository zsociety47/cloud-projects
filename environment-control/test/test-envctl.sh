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
esac
AZ
chmod +x "$T/bin/az"
export PATH="$T/bin:$PATH" ENVCTL_LOG_DIR="$T/log"

out=$("$HERE/envctl.sh")
echo "$out" | grep -q "would delete rg-old"   || { echo "FAIL dry run old";  exit 1; }
echo "$out" | grep -q "keeping rg-new"        || { echo "FAIL min-age";      exit 1; }
echo "$out" | grep -q "would delete rg-nodate"|| { echo "FAIL no created";   exit 1; }
grep -q "group delete" "$T/az.calls" && { echo "FAIL dry run deleted something"; exit 1; }
echo "PASS dry run deletes nothing"

"$HERE/envctl.sh" --apply >/dev/null
grep -q "group delete --name rg-old --yes --no-wait"    "$T/az.calls" || { echo "FAIL apply old";    exit 1; }
grep -q "group delete --name rg-nodate --yes --no-wait" "$T/az.calls" || { echo "FAIL apply nodate"; exit 1; }
grep -q "group delete --name rg-new"                    "$T/az.calls" && { echo "FAIL deleted new group"; exit 1; }
echo "PASS apply deletes old and undated, keeps new"
