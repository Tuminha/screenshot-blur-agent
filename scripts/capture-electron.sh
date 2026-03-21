#!/bin/bash
# capture-electron.sh - Bring an Electron app to front and capture a screenshot
# Usage: capture-electron.sh <app-name> [output-path]
#
# Example:
#   capture-electron.sh "Claude" /tmp/claude-screenshot.png
#   capture-electron.sh "Tana" /tmp/tana-screenshot.png
#   capture-electron.sh "Codex" /tmp/codex-screenshot.png

set -euo pipefail

APP="${1:?Usage: capture-electron.sh <app-name> [output-path]}"
OUTPUT="${2:-/tmp/${APP,,}-screenshot.png}"

echo "Bringing $APP to front..."
osascript -e "tell application \"$APP\" to activate"
sleep 1.5

echo "Capturing screenshot..."
/usr/sbin/screencapture -x "$OUTPUT"

echo "✅ Screenshot saved to $OUTPUT"
echo "   Dimensions: $(identify -format '%wx%h' "$OUTPUT")"
