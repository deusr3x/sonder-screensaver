#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/Library/Screen Savers"
SAVER_NAME="Sonder.saver"
DESTINATION="$TARGET_DIR/$SAVER_NAME"

echo "==> Installing Sonder Screen Saver..."

# 1. Determine source bundle
if [[ "${1:-}" == "--build" ]] || [[ ! -d "$SCRIPT_DIR/prebuilt/$SAVER_NAME" && ! -d "$SCRIPT_DIR/build/$SAVER_NAME" ]]; then
    echo "--> Compiling from source..."
    "$SCRIPT_DIR/build.sh"
    SOURCE_BUNDLE="$SCRIPT_DIR/build/$SAVER_NAME"
elif [[ -d "$SCRIPT_DIR/prebuilt/$SAVER_NAME" ]]; then
    echo "--> Using pre-built universal bundle (instant install)..."
    SOURCE_BUNDLE="$SCRIPT_DIR/prebuilt/$SAVER_NAME"
else
    SOURCE_BUNDLE="$SCRIPT_DIR/build/$SAVER_NAME"
fi

mkdir -p "$TARGET_DIR"

echo "--> Copying to $DESTINATION..."
rm -rf "$DESTINATION"
cp -R "$SOURCE_BUNDLE" "$DESTINATION"

# Ensure quarantine attributes are cleared for local execution
echo "--> Clearing macOS quarantine attributes..."
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
