#!/bin/bash
# Prints GitHub owner id and repository id for OpenID Connect subjects.
# Usage: ./oidc-ids.sh owner/name
# Inputs: a GitHub CLI login. The repository must exist.
# Output: two lines, owner_id= and repository_id=. No tokens.
# Side effects: none.

set -euo pipefail

if [[ $# -ne 1 || "$1" != */* ]]; then
  echo "usage: $0 owner/name" >&2
  exit 2
fi

gh api "repos/$1" --jq '"owner_id=\(.owner.id)\nrepository_id=\(.id)"'
