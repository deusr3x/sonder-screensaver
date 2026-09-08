#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

BUILD_DIR="$SCRIPT_DIR/build"
SAVER_BUNDLE="$BUILD_DIR/Sonder.saver"
PREVIEW_APP="$BUILD_DIR/SonderPreview.app"

echo "==> Building Sonder Screensaver for macOS..."

# Clean build directory
mkdir -p "$BUILD_DIR"
rm -rf "$SAVER_BUNDLE" "$PREVIEW_APP"

TMP_BUILD="$(mktemp -d)"
trap 'rm -rf "$TMP_BUILD"' EXIT

# Common source files
SAVER_SOURCES=(
  "$SCRIPT_DIR/Sources/SonderScreensaver/SonderLogo.swift"
  "$SCRIPT_DIR/Sources/SonderScreensaver/SonderPreferences.swift"
  "$SCRIPT_DIR/Sources/SonderScreensaver/SonderEffects.swift"
  "$SCRIPT_DIR/Sources/SonderScreensaver/SonderEngine.swift"
  "$SCRIPT_DIR/Sources/SonderScreensaver/ConfigurationView.swift"
  "$SCRIPT_DIR/Sources/SonderScreensaver/SonderScreenSaverView.swift"
)

PREVIEW_SOURCES=(
  "${SAVER_SOURCES[@]}"
  "$SCRIPT_DIR/Sources/SonderPreview/AppDelegate.swift"
  "$SCRIPT_DIR/Sources/SonderPreview/main.swift"
)

FRAMEWORKS=(
  -framework ScreenSaver
  -framework AppKit
  -framework Foundation
  -framework SwiftUI
)

# 1. Build Sonder.saver bundle (Universal: arm64 + x86_64)
echo "--> Compiling Sonder.saver bundle (universal: arm64 + x86_64)..."
mkdir -p "$SAVER_BUNDLE/Contents/MacOS"
mkdir -p "$SAVER_BUNDLE/Contents/Resources"

cp "$SCRIPT_DIR/Sources/SonderScreensaver/Info.plist" "$SAVER_BUNDLE/Contents/Info.plist"
cp "$SCRIPT_DIR/sonder-logo.txt" "$SAVER_BUNDLE/Contents/Resources/sonder-logo.txt"

swiftc -target arm64-apple-macos12.0 -emit-library -Xlinker -bundle \
  "${SAVER_SOURCES[@]}" "${FRAMEWORKS[@]}" \
  -module-name Sonder -O -o "$TMP_BUILD/Sonder_arm64"

swiftc -target x86_64-apple-macos12.0 -emit-library -Xlinker -bundle \
  "${SAVER_SOURCES[@]}" "${FRAMEWORKS[@]}" \
  -module-name Sonder -O -o "$TMP_BUILD/Sonder_x86"

lipo -create "$TMP_BUILD/Sonder_arm64" "$TMP_BUILD/Sonder_x86" -output "$SAVER_BUNDLE/Contents/MacOS/Sonder"
codesign --force --deep -s - "$SAVER_BUNDLE"

# 2. Build SonderPreview.app standalone application (Universal: arm64 + x86_64)
echo "--> Compiling SonderPreview.app application (universal: arm64 + x86_64)..."
mkdir -p "$PREVIEW_APP/Contents/MacOS"
mkdir -p "$PREVIEW_APP/Contents/Resources"

cp "$SCRIPT_DIR/Sources/SonderPreview/Info.plist" "$PREVIEW_APP/Contents/Info.plist"
cp "$SCRIPT_DIR/sonder-logo.txt" "$PREVIEW_APP/Contents/Resources/sonder-logo.txt"

swiftc -target arm64-apple-macos12.0 \
  "${PREVIEW_SOURCES[@]}" "${FRAMEWORKS[@]}" \
  -module-name SonderPreview -O -o "$TMP_BUILD/Preview_arm64"

swiftc -target x86_64-apple-macos12.0 \
  "${PREVIEW_SOURCES[@]}" "${FRAMEWORKS[@]}" \
  -module-name SonderPreview -O -o "$TMP_BUILD/Preview_x86"

lipo -create "$TMP_BUILD/Preview_arm64" "$TMP_BUILD/Preview_x86" -output "$PREVIEW_APP/Contents/MacOS/SonderPreview"
codesign --force --deep -s - "$PREVIEW_APP"

echo ""
echo "✅ Build succeeded! (Universal binaries: Apple Silicon + Intel)"
echo "   • Screen Saver Bundle : $SAVER_BUNDLE"
echo "   • Standalone Preview  : $PREVIEW_APP"

