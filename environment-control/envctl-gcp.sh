#!/usr/bin/env bash
# Dry-run sweep of Google Cloud projects labeled lifetime=1d.
# Pass --apply to delete those projects. This script does not sweep
# Azure or Amazon Web Services.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
for arg in "$@"; do
  if [ "$arg" = "--cloud" ]; then
    echo "envctl-gcp.sh sweeps Google Cloud only." >&2
    exit 2
  fi
done
exec "$HERE/envctl.sh" --cloud gcp --sweep-only "$@"
