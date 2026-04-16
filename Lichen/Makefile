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
	$(KIT_SOURCE_DIR)/SSKScreenUtilities.m \
	$(KIT_SOURCE_DIR)/SSKDiagnostics.m \
	$(KIT_SOURCE_DIR)/SSKPreferenceBinder.m \
	$(KIT_SOURCE_DIR)/SSKConfigurationWindowController.m \
	$(KIT_SOURCE_DIR)/SSKColorPalette.m \
	$(KIT_SOURCE_DIR)/SSKPaletteManager.m \
	$(KIT_SOURCE_DIR)/SSKColorUtilities.m \
	$(KIT_SOURCE_DIR)/SSKParticleSystem.m

THUMBNAIL_BMP := $(CURRENT_DIR)/thumbnail.bmp
THUMBNAIL_PNG := $(RESOURCES_DIR)/thumbnail.png
THUMBNAIL_PNG_2X := $(RESOURCES_DIR)/thumbnail@2x.png

INFO_PLIST := $(CURRENT_DIR)/Info.plist
EXECUTABLE := $(MACOS_DIR)/$(SCREENSAVER_NAME)

.PHONY: all clean install run bench

all: $(EXECUTABLE) $(THUMBNAIL_PNG) $(THUMBNAIL_PNG_2X)

$(EXECUTABLE): $(SOURCES) $(CONTENTS_DIR)/Info.plist | $(MACOS_DIR)
	@mkdir -p $(MODULE_CACHE_DIR)
	$(CC) $(CFLAGS) $(LDFLAGS) $(FRAMEWORKS) -bundle -o $@ $(SOURCES)

$(CONTENTS_DIR)/Info.plist: $(INFO_PLIST) | $(MACOS_DIR)
	cp "$<" "$@"
	/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable $(SCREENSAVER_NAME)" "$@"
	/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $(BUNDLE_ID)" "$@"
	/usr/libexec/PlistBuddy -c "Set :NSPrincipalClass $(PRINCIPAL_CLASS)" "$@"

$(THUMBNAIL_PNG): $(THUMBNAIL_BMP) | $(MACOS_DIR)
	sips -s format png -z 180 288 "$<" --out "$@" >/dev/null

$(THUMBNAIL_PNG_2X): $(THUMBNAIL_BMP) | $(MACOS_DIR)
	sips -s format png -z 360 576 "$<" --out "$@" >/dev/null

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
