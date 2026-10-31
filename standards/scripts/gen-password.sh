#!/usr/bin/env bash
# Generate a password that meets this portfolio's usual Windows / Terraform checks:
# at least --length characters (default 16), with uppercase, lowercase, a digit,
# and a symbol; no double quote, dollar sign, or backtick; and do not contain
# --username (case-insensitive) when that flag is set.
#
# Canonical copy: cloud-projects/standards/scripts/gen-password.sh
# Project repos keep the same script under scripts/ so a single-repo clone works.
#
# Usage:
#   ./gen-password.sh
#   ./gen-password.sh --length 20 --username migrateadmin
# Prints one password to stdout. Redirect into a gitignored file or export it.
# Do not commit the value. Do not paste it into chat logs if you can avoid it.

set -euo pipefail

LENGTH=16
USERNAME=""

usage() {
  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --length)
      LENGTH="${2:?--length needs a number}"
      shift 2
      ;;
    --username)
      USERNAME="${2:?--username needs a value}"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if ! [[ "$LENGTH" =~ ^[0-9]+$ ]] || ((LENGTH < 12)) || ((LENGTH > 123)); then
  echo "--length must be an integer from 12 to 123" >&2
  exit 1
fi

# Omit " $ ` so Azure/Windows and this portfolio's Terraform validation stay happy.
ALPHANUM='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
SYMBOL='!#%@^*()-_=+[]{}:;,.?/'
ALL="${ALPHANUM}${SYMBOL}"

pick() {
  local alphabet="$1"
  local n="${#alphabet}"
  local idx
  idx="$(od -An -N2 -tu2 </dev/urandom | tr -d ' ')"
  idx=$((idx % n))
  printf '%s' "${alphabet:idx:1}"
}

is_valid() {
  local p="$1"
  [[ ${#p} -ge $LENGTH ]] || return 1
  [[ "$p" =~ [A-Z] ]] || return 1
  [[ "$p" =~ [a-z] ]] || return 1
  [[ "$p" =~ [0-9] ]] || return 1
  [[ "$p" =~ [^A-Za-z0-9] ]] || return 1
  [[ "$p" != *'"'* && "$p" != *'$'* && "$p" != *'`'* ]] || return 1
  if [[ -n "$USERNAME" ]]; then
    local lower_p lower_u
    lower_p="$(printf '%s' "$p" | tr '[:upper:]' '[:lower:]')"
    lower_u="$(printf '%s' "$USERNAME" | tr '[:upper:]' '[:lower:]')"
    [[ "$lower_p" != *"$lower_u"* ]] || return 1
  fi
  return 0
}

for _ in $(seq 1 200); do
  # Guarantee one of each class, then fill the rest from the full alphabet.
  password=""
  password+="$(pick 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"
  password+="$(pick 'abcdefghijklmnopqrstuvwxyz')"
  password+="$(pick '0123456789')"
  password+="$(pick "$SYMBOL")"
  while [[ ${#password} -lt $LENGTH ]]; do
    password+="$(pick "$ALL")"
  done
  # Shuffle characters (portable Fisher–Yates with /dev/urandom).
  shuffled=""
  rest="$password"
  while [[ ${#rest} -gt 0 ]]; do
    i="$(od -An -N2 -tu2 </dev/urandom | tr -d ' ')"
    i=$((i % ${#rest}))
    shuffled+="${rest:i:1}"
    rest="${rest:0:i}${rest:i+1}"
  done
  if is_valid "$shuffled"; then
    printf '%s\n' "$shuffled"
    exit 0
  fi
done

echo "could not generate a valid password in 200 tries" >&2
exit 1
