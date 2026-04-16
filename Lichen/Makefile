CURRENT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
KIT_DIR := $(abspath $(CURRENT_DIR)/..)
KIT_SOURCE_DIR := $(KIT_DIR)/ScreenSaverKit/ScreenSaverKit

SCREENSAVER_NAME ?= Lichen
BUNDLE_ID ?= com.janbridley.lichen
PRINCIPAL_CLASS ?= LichenView
BUILD_DIR ?= $(CURRENT_DIR)/Build

BUNDLE_DIR := $(BUILD_DIR)/$(SCREENSAVER_NAME).saver
CONTENTS_DIR := $(BUNDLE_DIR)/Contents
MACOS_DIR := $(CONTENTS_DIR)/MacOS
RESOURCES_DIR := $(CONTENTS_DIR)/Resources
MODULE_CACHE_DIR := $(BUILD_DIR)/ModuleCache

CC := clang
CFLAGS := -Wall -Wextra -O2 -fobjc-arc -fmodules -arch arm64 -arch x86_64 \
	-fmodules-cache-path=$(MODULE_CACHE_DIR) -I$(KIT_DIR)/ScreenSaverKit
LDFLAGS := -Wl,-dead_strip
FRAMEWORKS := -framework Cocoa -framework ScreenSaver -framework QuartzCore

SOURCES := \
	$(CURRENT_DIR)/LichenView.m \
	$(KIT_SOURCE_DIR)/SSKScreenSaverView.m \
	$(KIT_SOURCE_DIR)/SSKAssetManager.m \
	$(KIT_SOURCE_DIR)/SSKAnimationClock.m \
	$(KIT_SOURCE_DIR)/SSKEntityPool.m \
	$(KIT_SOURCE_DIR)/SSKDiagnostics.m

THUMBNAIL_BMP := $(CURRENT_DIR)/thumbnail.bmp
ICONSET_DIR := $(BUILD_DIR)/Lichen.iconset
ICON_ICNS := $(RESOURCES_DIR)/Lichen.icns

INFO_PLIST := $(CURRENT_DIR)/Info.plist
EXECUTABLE := $(MACOS_DIR)/$(SCREENSAVER_NAME)

.PHONY: all clean install run bench

all: $(EXECUTABLE) $(ICON_ICNS)

$(EXECUTABLE): $(SOURCES) $(CONTENTS_DIR)/Info.plist | $(MACOS_DIR)
	@mkdir -p $(MODULE_CACHE_DIR)
	$(CC) $(CFLAGS) $(LDFLAGS) $(FRAMEWORKS) -bundle -o $@ $(SOURCES)

$(CONTENTS_DIR)/Info.plist: $(INFO_PLIST) | $(MACOS_DIR)
	cp "$<" "$@"

SQUARE_PNG := $(BUILD_DIR)/thumbnail_square.png

$(SQUARE_PNG): $(THUMBNAIL_BMP) | $(MACOS_DIR)
	sips -s format png -c 800 800 "$(THUMBNAIL_BMP)" --out "$@" >/dev/null

$(ICONSET_DIR): $(SQUARE_PNG) | $(MACOS_DIR)
	@mkdir -p "$@"
	sips -z 16 16 "$<" --out "$@/icon_16x16.png" >/dev/null
	sips -z 32 32 "$<" --out "$@/icon_16x16@2x.png" >/dev/null
	sips -z 32 32 "$<" --out "$@/icon_32x32.png" >/dev/null
	sips -z 64 64 "$<" --out "$@/icon_32x32@2x.png" >/dev/null
	sips -z 128 128 "$<" --out "$@/icon_128x128.png" >/dev/null
	sips -z 256 256 "$<" --out "$@/icon_128x128@2x.png" >/dev/null
	sips -z 256 256 "$<" --out "$@/icon_256x256.png" >/dev/null
	sips -z 512 512 "$<" --out "$@/icon_256x256@2x.png" >/dev/null
	sips -z 512 512 "$<" --out "$@/icon_512x512.png" >/dev/null
	sips -z 1024 1024 "$<" --out "$@/icon_512x512@2x.png" >/dev/null

$(ICON_ICNS): $(ICONSET_DIR)
	iconutil -c icns "$<" -o "$@"

$(MACOS_DIR):
	@mkdir -p $(MACOS_DIR)
	@mkdir -p $(RESOURCES_DIR)

clean:
	rm -rf "$(BUILD_DIR)"

install: all
	cp -R "$(BUNDLE_DIR)" /Library/Screen\ Savers/
	open /Library/Screen\ Savers/

run: install
	open -a ScreenSaverEngine "$(BUNDLE_DIR)"

bench:
	@echo "Building and running Lichen benchmark..."
	@$(MAKE) -C "$(CURRENT_DIR)/Tools/Benchmark"
	@$(CURRENT_DIR)/Tools/Benchmark/Build/lichen-benchmark
