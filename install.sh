#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/Library/Screen Savers"
SAVER_NAME="Sonder.saver"
DESTINATION="$TARGET_DIR/$SAVER_NAME"

echo "==> Installing Sonder Screen Saver..."

# Build if needed
"$SCRIPT_DIR/build.sh"

mkdir -p "$TARGET_DIR"

echo "--> Copying to $DESTINATION..."
rm -rf "$DESTINATION"
cp -R "$SCRIPT_DIR/build/$SAVER_NAME" "$DESTINATION"

# Ensure quarantine attributes are cleared for local execution
xattr -cr "$DESTINATION" 2>/dev/null || true

# Terminate any cached legacyScreenSaver instances so macOS reloads the bundle
echo "--> Refreshing macOS screen saver service..."
killall -9 legacyScreenSaver 2>/dev/null || true
killall -9 ScreenSaverEngine 2>/dev/null || true

echo ""
echo "🎉 Installation complete!"
echo "   Sonder is now installed at: $DESTINATION"
echo ""
echo "To activate it:"
echo "1. Open System Settings -> Wallpaper & Screen Saver (or Screen Saver)."
echo "2. Find 'Sonder' under the Other / Screen Saver section and select it."
echo "3. Click 'Options...' to customize effects, speed, hold time, or background."
echo ""
echo "Tip: You can also run './run-preview.sh' to preview the screensaver anytime in a window or full screen!"
