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
including `Lichen.icns` in the bundle's Resources. The icon is generated from
`thumbnail.bmp` via `sips` and `iconutil`, and referenced by `CFBundleIconFile` in
`Info.plist`.

## Bump version

Update `CFBundleShortVersionString` and `CFBundleVersion` in `Info.plist`.

## Code-sign

```bash
codesign --force --timestamp --options runtime \
  --identifier com.janbridley.lichen \
  --sign "Developer ID Application: NAME (TEAMID)" \
  Build/Lichen.saver
```

Verify:

```bash
codesign --verify --strict --verbose=2 Build/Lichen.saver
```

## Notarize

```bash
ditto -c -k --keepParent Build/Lichen.saver Build/Lichen.saver.zip

xcrun notarytool submit Build/Lichen.saver.zip \
  --keychain-profile lichen-notary --wait
```

## Distribute

Create a github release with the signed + notarized `.saver.zip`. Users unzip and copy
to `~/Library/Screen Savers/`, or double-click to install automatically.
