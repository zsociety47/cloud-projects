#!/usr/bin/env bash
# Installs the nightly 11:30 PM sweep on macOS. Run it yourself, on the Mac.
#   ./install-launchd.sh            install (runs envctl.sh --apply --cloud all every night)
#   ./install-launchd.sh --remove   uninstall
# If the Mac is asleep at 11:30 PM, launchd runs the job when it wakes.
#
# macOS does not let that nightly job read a script on the Desktop. The job
# used to point at this folder and exit 126, "Operation not permitted", so
# nothing was deleted. The install copies envctl.sh to ~/.environment-control
# and points the job at that copy. Run this again after you change envctl.sh.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
LOGDIR="$HOME/.environment-control"
DEST="$HOME/Library/LaunchAgents/com.zeon.envctl.plist"
mkdir -p "$LOGDIR" "$HOME/Library/LaunchAgents"
if [ "${1:-}" = "--remove" ]; then
  launchctl unload "$DEST" 2>/dev/null || true
  rm -f "$DEST"; echo "Removed."; exit 0
fi
cp "$HERE/envctl.sh" "$LOGDIR/envctl.sh"
chmod +x "$LOGDIR/envctl.sh"
cat > "$LOGDIR/run-envctl.sh" << EOF
#!/bin/bash
set -u
if [ -r "$HERE/envctl.sh" ]; then
  cp "$HERE/envctl.sh" "$LOGDIR/envctl.sh"
  chmod +x "$LOGDIR/envctl.sh"
fi
export PATH="/opt/homebrew/bin:/usr/local/bin:\$HOME/google-cloud-sdk/bin:\$HOME/Downloads/google-cloud-sdk/bin:/opt/homebrew/share/google-cloud-sdk/bin:/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin:/usr/bin:/bin"
exec /bin/bash "$LOGDIR/envctl.sh" --apply --cloud all
EOF
chmod +x "$LOGDIR/run-envctl.sh"
sed -e "s#__SCRIPT__#$LOGDIR/run-envctl.sh#" -e "s#__LOGDIR__#$LOGDIR#g" "$HERE/launchd/com.zeon.envctl.plist.template" > "$DEST"
launchctl unload "$DEST" 2>/dev/null || true
launchctl load "$DEST"
echo "Installed. The nightly job runs $LOGDIR/run-envctl.sh"
echo "First do a dry run:  $HERE/envctl.sh"
echo "Logs: $LOGDIR/envctl.log"
