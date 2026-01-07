# lichen

A macOS screensaver based on the MS-DOS virus
["lichen"](https://archive.org/details/virus-dos-lichen-1024-example). This library uses
[ScreenSaverKit](https://github.com/fuzzywalrus/ScreenSaverKit) and a Metal kernel for
GPU acceleration, allowing for extremely low power consumption while the screensaver
plays.

![lichen](static/lichen_2x_2x_20fps_opt.gif)

## Developer Instructions

```bash
# Build and open the image. May require sudo to install to /Library/Screen\ Savers
../ScreenSaverKit/scripts/install-and-refresh.sh . && open -a ScreenSaverEngine
```

### Performance
