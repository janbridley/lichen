# Release Process

## Generate thumbnail

```bash
cd static && python3 lichen_thumbnail.py
```

This simulates the lichen automaton up to `THUMBNAIL_FRAME` and writes a bitmap to
`Lichen/thumbnail.bmp`.

## Build

```bash
cd Lichen && make clean all
```

This produces a universal (arm64 + x86_64) bundle at `Lichen/Build/Lichen.saver`,
including `thumbnail.png` and `thumbnail@2x.png` in the bundle's Resources. Note that,
[as of recently](https://developer.apple.com/forums/thread/806641), these thumbnail
files do not change how the screensaver displays in system settings.

## Bump version

Update `CFBundleShortVersionString` and `CFBundleVersion` in `Info.plist`.

## Code-sign

```bash
codesign --force --timestamp --options runtime \
  --identifier com.janbridley.lichen \
  --sign "Developer ID Application: NAME (TEAMID)" \
  Lichen/Build/Lichen.saver
```

Verify:

```bash
codesign --verify --strict --verbose=2 Lichen/Build/Lichen.saver
```

## Notarize

```bash
ditto -c -k --keepParent Lichen/Build/Lichen.saver Lichen/Build/Lichen.saver.zip

xcrun notarytool submit Lichen/Build/Lichen.saver.zip \
  --keychain-profile your-notary-profile --wait
```

## Distribute

Create a github release with the signed + notarized `.saver.zip`. Users unzip and copy
to `~/Library/Screen Savers/`, or double-click to install automatically.
