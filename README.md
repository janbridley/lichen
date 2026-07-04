# lichen

A macOS screensaver based on the MS-DOS virus
["lichen"](https://archive.org/details/virus-dos-lichen-1024-example). Lichen ships as a
modern app-extension (appex) screensaver for macOS 14 (Sonoma) and later, derived from
the [AppexSaverMinimal](https://github.com/AerialScreensaver/AppexSaverMinimal) appex
pattern. The simulation runs on the CPU and is drawn to the screen through Core
Animation with nearest-neighbor upscaling.

![lichen](static/lichen_2x_2x_20fps_opt.gif)

## Mathematics and Python Implementation

*lichen* is a cellular automaton on a pixel grid initialized with a single pixel of
value `0x1E`. On each simulation step, a random pixel index is chosen and modified
according to the following rules:

```python
if image[pixel_idx] == 0x00:
    continue
image[pixel_idx] -= 1
if image[pixel_idx] < 0x17:
    continue
# Spread pixel, respecting a horizontal periodic boundary
for neighbor_idx in (up, down, left, right):
    if image[neighbor_idx] == 0:
        image[neighbor_idx] = 0x1E
```

The add-rotate-xor generator is seeded according to the original DOS program, and can be
implemented as follows. Note that this assumes we have an output resolution less than ~1
Megapixel. For larger images, the mask `0x000FFFFF` can be reduced -- however, it may
take many steps to randomly select the initial nonzero pixel, resulting in a long gap
before we observe changes to the simulation state. In these cases, it is useful to jump
the generator to a state that modifies the desired pixel, or implement additional logic
to randomly select only non-zero pixels. Note that doing so does change the dynamics of
the original virus, so this implementation chooses to faithfully represent both the
original resolution and simulation rules. When run as a screensaver, the OS expands the
image buffer to the correct display resolution.

```python
MAGIC_CONST = 0x5A6A6D6C  # LCG constant
while idx >= TOTAL_PIXELS:
    esi = (esi + MAGIC_CONST) & 0xFFFFFFFF
    esi = ((esi >> 1) | (esi << 31)) & 0xFFFFFFFF
    pixel_idx = esi & 0x000FFFFF
```

## Requirements

- macOS 14 (Sonoma) or later
- Xcode (with command-line tools)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

## Build & install

```sh
git clone https://github.com/janbridley/lichen.git
cd lichen
sh build-and-install.sh  # xcodegen -> build -> register appex -> launch
```

The host app's window has **Install** and **Enable as Screensaver** buttons and an
**Open Preview** window. After enabling, trigger it with `open -a ScreenSaverEngine`, or
pick Lichen in **System Settings -> Screen Saver**.

To install permanently, copy the built app into `/Applications` — macOS auto-discovers
the embedded appex and Lichen appears in **System Settings -> Screen Saver**:

```sh
cp -R build/DerivedData/Build/Products/Release/Lichen.app /Applications/
```

## Developer Guide

The actual simulation code for the screensaver is in
`Sources/Lichen/LichenAnimator.swift`. All other files are either swiftui tie-ins or
various build components.
