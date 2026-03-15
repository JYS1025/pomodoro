#!/usr/bin/env bash
# build.sh — Builds Pomodoro.app from the Swift Package
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PKG_DIR="$SCRIPT_DIR/Pomodoro"
ASSETS_DIR="$SCRIPT_DIR/Assets"
OUT_DIR="$SCRIPT_DIR/build"
APP="$OUT_DIR/Pomodoro.app"

echo "Building release binary..."
cd "$PKG_DIR"
swift build -c release 2>&1 | tail -3

BINARY="$PKG_DIR/.build/release/Pomodoro"

echo "Assembling Pomodoro.app..."
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

cp "$BINARY"                          "$APP/Contents/MacOS/Pomodoro"
cp "$PKG_DIR/Info.plist"              "$APP/Contents/Info.plist"
cp "$ASSETS_DIR/AppIcon.icns"         "$APP/Contents/Resources/AppIcon.icns"

# Ad-hoc code sign (no Apple Developer account required)
codesign --force --deep --sign - "$APP"

echo ""
echo "Done: $APP"
echo "To install: cp -r '$APP' /Applications/"
