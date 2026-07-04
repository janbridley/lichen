#!/bin/sh
# Build Lichen, register the embedded appex with macOS, and launch the host app.
#
# After this script: in the app window click "Enable as Screensaver" (PaperSaver),
# then trigger the real thing with:  open -a ScreenSaverEngine
#
# Run with:  sh build-and-install.sh     (or ./build-and-install.sh after chmod +x)
set -e
cd "$(dirname "$0")"

PROJECT=Lichen.xcodeproj
SCHEME=Lichen
DERIVED=build/DerivedData
APP="$DERIVED/Build/Products/Debug/Lichen.app"
APPEX="$APP/Contents/PlugIns/LichenExtension.appex"

echo "==> Regenerate the Xcode project (xcodegen)"
xcodegen generate

echo "==> Build (Debug)"
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration Debug \
    -derivedDataPath "$DERIVED" -quiet build

echo "==> Stop any running Lichen instances"
killall Lichen 2>/dev/null || true

echo "==> Register the appex with macOS (pluginkit)"
pluginkit -a "$APPEX"

echo "==> Launch the host app"
open "$APP"

cat <<EOF

Done. Next:
  1. In the app: click "Enable as Screensaver".
  2. Trigger the screensaver:  open -a ScreenSaverEngine
EOF
