#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

DIST_DIR="$SCRIPT_DIR/dist"
STAGE_DIR="$DIST_DIR/stage"
ZIP_NAME="Sonder-Screensaver.zip"

echo "==> Packaging Sonder Screen Saver for distribution..."

# 1. Ensure latest universal build
"$SCRIPT_DIR/build.sh"

# 2. Prepare clean staging directory
rm -rf "$DIST_DIR"
mkdir -p "$STAGE_DIR"

# 3. Copy Sonder.saver
cp -R "$SCRIPT_DIR/build/Sonder.saver" "$STAGE_DIR/Sonder.saver"

# 4. Create one-click installer script (.command)
cat << 'INSTALLER_EOF' > "$STAGE_DIR/Install-Sonder.command"
#!/bin/bash
set -euo pipefail

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SAVER_SRC="$DIR/Sonder.saver"
TARGET_DIR="$HOME/Library/Screen Savers"
DEST="$TARGET_DIR/Sonder.saver"

echo "================================================"
echo "    Sonder Screen Saver Installer for macOS     "
echo "================================================"
echo ""

if [ ! -d "$SAVER_SRC" ]; then
    echo "Error: Sonder.saver not found in the same directory."
    exit 1
fi

mkdir -p "$TARGET_DIR"
echo "--> Installing to $DEST..."
rm -rf "$DEST"
cp -R "$SAVER_SRC" "$DEST"

# Remove quarantine attribute attached by macOS when downloaded
echo "--> Removing download quarantine attribute..."
xattr -cr "$DEST" 2>/dev/null || true

# Refresh macOS screensaver engine
echo "--> Refreshing macOS screensaver engine..."
killall -9 legacyScreenSaver 2>/dev/null || true
killall -9 ScreenSaverEngine 2>/dev/null || true

echo ""
echo "✅ Sonder Screen Saver successfully installed!"
echo ""
echo "Opening System Settings -> Wallpaper & Screen Saver..."
open "x-apple.systempreferences:com.apple.Wallpaper-Settings.extension" 2>/dev/null || \
open "x-apple.systempreferences:com.apple.preference.desktopscreeneffect" 2>/dev/null || \
open -b com.apple.systempreferences 2>/dev/null || true

echo "Done! Select 'Sonder' from the Screen Saver list."
echo ""
read -n 1 -s -r -p "Press any key to close this window..."
echo ""
INSTALLER_EOF
chmod +x "$STAGE_DIR/Install-Sonder.command"

# 5. Create README.txt for recipients
cat << 'README_EOF' > "$STAGE_DIR/README.txt"
Sonder Screen Saver for macOS
=============================

Compatible with all Macs running macOS 12 Monterey or later
(Universal binary: native on Apple Silicon M1/M2/M3/M4 & Intel Macs).

HOW TO INSTALL
--------------
Method 1: One-Click Installer (Recommended)
1. Double-click "Install-Sonder.command".
   (If macOS asks for confirmation the first time, right-click and choose "Open").
2. It will copy the screen saver to your Library and open System Settings.
3. Select "Sonder" from the list of Screen Savers!

Method 2: Manual Installation
1. Move or copy "Sonder.saver" to:
   ~/Library/Screen Savers/
   (In Finder, press Shift+Cmd+G, paste "~/Library/Screen Savers", and press Enter).
2. Open System Settings -> Wallpaper & Screen Saver.
3. Select "Sonder".

HOW TO CUSTOMIZE
----------------
In System Settings -> Wallpaper & Screen Saver:
Click "Options..." next to Sonder to choose:
- Animation effect (Synthgrid, Pour, Waves, Smoke, Slice, Unstable, Scattered, Sweep, Rings, Middle-Out, or Random)
- Animation speed multiplier
- Hold duration on complete logo
- Neon glow intensity
- Background color (Deep Sonder Navy, Pitch Black, or Subtle Indigo)

NOTES ON MACOS SECURITY (GATEKEEPER)
-----------------------------------
If macOS displays a notice saying "Sonder.saver cannot be opened because the developer cannot be verified":
- Simply use "Install-Sonder.command" (it automatically clears the download quarantine).
- Alternatively: Go to System Settings -> Privacy & Security, scroll down to the Security section, and click "Open Anyway".
README_EOF

# 6. Create clean ZIP archives (without macOS resource forks or ._ files)
cd "$STAGE_DIR"
zip -r -X -q "$DIST_DIR/Sonder.saver.zip" "Sonder.saver"
zip -r -X -q "$DIST_DIR/$ZIP_NAME" "Sonder.saver" "Install-Sonder.command" "README.txt"

# Clean up stage
rm -rf "$STAGE_DIR"

echo ""
echo "🎉 Packaging complete!"
echo "   Ready-to-share archive created at:"
echo "   $DIST_DIR/$ZIP_NAME"
echo ""
echo "Recipients can unzip and either double-click 'Install-Sonder.command' or 'Sonder.saver'."
