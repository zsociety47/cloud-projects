#!/usr/bin/env bash
# Dry-run sweep of Amazon Web Services resources tagged lifetime=1d.
# Pass --apply to delete instances, volumes, snapshots, NAT gateways, addresses,
# load balancers, databases (no final snapshot), and buckets. Networks are listed and left. This script does not sweep Azure
# or Google Cloud.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
for arg in "$@"; do
  if [ "$arg" = "--cloud" ]; then
    echo "envctl-aws.sh sweeps Amazon Web Services only." >&2
    exit 2
  fi
done
exec "$HERE/envctl.sh" --cloud aws --sweep-only "$@"
