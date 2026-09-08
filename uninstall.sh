#!/bin/bash
set -euo pipefail

DESTINATION="$HOME/Library/Screen Savers/Sonder.saver"

echo "==> Uninstalling Sonder Screen Saver..."

if [ -d "$DESTINATION" ]; then
    rm -rf "$DESTINATION"
    killall -9 legacyScreenSaver 2>/dev/null || true
    killall -9 ScreenSaverEngine 2>/dev/null || true
    echo "✅ Removed: $DESTINATION"
else
    echo "ℹ️  Sonder Screen Saver is not installed at $DESTINATION"
fi
