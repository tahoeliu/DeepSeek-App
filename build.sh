#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$ROOT/Build"
APP_DIR="$ROOT/DeepSeek.app"

mkdir -p "$BUILD_DIR" "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

# 1. compile
swiftc -O -target arm64-apple-macos11.0 -framework AppKit -framework WebKit \
  -o "$BUILD_DIR/DeepSeek" \
  "$ROOT/Sources/main.swift"

# 2. assemble bundle
cp "$BUILD_DIR/DeepSeek"  "$APP_DIR/Contents/MacOS/DeepSeek"
cp "$ROOT/Resources/Info.plist" "$APP_DIR/Contents/Info.plist"
cp "$ROOT/Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
chmod +x "$APP_DIR/Contents/MacOS/DeepSeek"

# 3. ad-hoc sign and verify; this is not Developer ID notarization.
codesign --force --deep --sign - "$APP_DIR"
codesign --verify --deep --strict "$APP_DIR"

echo "==> $APP_DIR"
ls -la "$APP_DIR/Contents"
echo "==> Done."
