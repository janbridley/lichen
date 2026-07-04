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
CONFIG=${1:-Release}   # sh build-and-install.sh [Debug|Release]
APP="$DERIVED/Build/Products/$CONFIG/Lichen.app"
APPEX="$APP/Contents/PlugIns/LichenExtension.appex"

echo "==> Stop any running Lichen instances"
killall Lichen 2>/dev/null || true

echo "==> Unregister every previously-registered Lichen appex (kills stale builds)"
pluginkit -m -v -p com.apple.screensaver 2>/dev/null | grep -i lichen \
    | grep -o '/[^ ]*\.appex' | sort -u | while read -r old; do
    echo "  - $old"
    pluginkit -r "$old" 2>/dev/null || true
done

echo "==> Regenerate the Xcode project (xcodegen)"
xcodegen generate

echo "==> Clean build dir (avoids stale appex being registered)"
rm -rf "$DERIVED"

echo "==> Build ($CONFIG)"
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIG" \
    -derivedDataPath "$DERIVED" -destination "platform=macOS,arch=arm64" \
    -quiet build

echo "==> Register the freshly built appex"
pluginkit -a "$APPEX"

echo "==> Launch the host app"
open "$APP"

cat <<EOF

Done. Next:
  1. In the app: click "Enable as Screensaver".
  2. Trigger the screensaver:  open -a ScreenSaverEngine
EOF
