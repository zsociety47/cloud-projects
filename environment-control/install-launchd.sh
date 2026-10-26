#!/usr/bin/env bash
# Installs the nightly 11:30 PM sweep on macOS. Run it yourself, on the Mac.
#   ./install-launchd.sh            install (runs envctl.sh --apply --cloud all every night)
#   ./install-launchd.sh --remove   uninstall
# If the Mac is asleep at 11:30 PM, launchd runs the job when it wakes.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
LOGDIR="$HOME/.environment-control"
DEST="$HOME/Library/LaunchAgents/com.zeon.envctl.plist"
mkdir -p "$LOGDIR" "$HOME/Library/LaunchAgents"
if [ "${1:-}" = "--remove" ]; then
  launchctl unload "$DEST" 2>/dev/null || true
  rm -f "$DEST"; echo "Removed."; exit 0
fi
sed -e "s#__SCRIPT__#$HERE/envctl.sh#" -e "s#__LOGDIR__#$LOGDIR#g" "$HERE/launchd/com.zeon.envctl.plist.template" > "$DEST"
launchctl unload "$DEST" 2>/dev/null || true
launchctl load "$DEST"
echo "Installed. First do a dry run:  $HERE/envctl.sh"
echo "Logs: $LOGDIR/envctl.log"
