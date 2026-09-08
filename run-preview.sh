#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PREVIEW_APP="$SCRIPT_DIR/build/SonderPreview.app"
BINARY="$PREVIEW_APP/Contents/MacOS/SonderPreview"

if [ ! -f "$BINARY" ]; then
    echo "==> Building Sonder Screensaver Preview..."
    "$SCRIPT_DIR/build.sh"
fi

echo "==> Launching Sonder Screensaver Preview..."
echo "    • Space       : Advance to next effect"
echo "    • Keys 1-0    : Jump to specific effect (1: Synthgrid, 2: Pour, 3: Waves, etc.)"
echo "    • F           : Toggle Full Screen"
echo "    • C           : Open Settings / Configuration Sheet"
echo "    • Esc / Q     : Quit preview"
echo ""

if [[ "${1:-}" == "--bg" ]]; then
    open "$PREVIEW_APP"
else
    # Run in foreground so window is focused and stays open until closed
    "$BINARY" "$@"
fi
