#import "LichenView.h"
#import <AppKit/AppKit.h>
#import "ScreenSaverKit/SSKDiagnostics.h"

static const NSInteger kWidth            = 320;
static const NSInteger kHeight           = 200;
static const NSInteger kTotalPixels      = kWidth * kHeight;
static const uint8_t   kMaxBrightness    = 0x1E;
static const uint8_t   kSpreadThreshold  = 0x17;
static const uint32_t  lcgConst          = 0x5A6A6D6C;
static const uint32_t  lcgSeed           = 0x00000361;

@interface LichenView ()
@property (nonatomic) uint8_t *imageBuffer;
@property (nonatomic) uint32_t esi;
@property (nonatomic, strong) NSBitmapImageRep *bitmap;
@property (nonatomic, strong) NSImage *renderedImage;
@property (nonatomic) CGFloat scale;
@property (nonatomic) NSPoint origin;
@end

@implementation LichenView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    if ((self = [super initWithFrame:frame isPreview:isPreview])) {
        self.animationTimeInterval = 1.0 / 60.0;
        self.stepsPerFrame = 4000;

        [self initializeLichen];
    }
    return self;
}

- (void)initializeLichen {
    // Allocate image buffer (320 x 200 pixels)
    self.imageBuffer = calloc(kTotalPixels, sizeof(uint8_t));
    if (!self.imageBuffer) {
        NSLog(@"Lichen: Failed to allocate image buffer");
        return;
    }

    // Initialize PRNG state
    self.esi = lcgSeed;

    // Place initial spore at center
    NSInteger centerX = kWidth / 2;
    NSInteger centerY = kHeight / 2;
    NSInteger centerIdx = centerY * kWidth + centerX;
    self.imageBuffer[centerIdx] = kMaxBrightness;
}

- (void)dealloc {
    free(self.imageBuffer);
}

- (bool)isOpaque { return true; }

- (void)animateOneFrame {
    NSTimeInterval dt = [self advanceAnimationClock];
    if (dt <= 0) { dt = 1.0 / 60.0; }

    // Run the lichen algorithm for configured steps per frame
    for (NSUInteger i = 0; i < self.stepsPerFrame; i++) {
        [self processOneStep];
    }

    [self updateRenderedImage];
    [self setNeedsDisplay:YES];
}

- (void)processOneStep {
    // Generate a valid pixel index using an LCG
    NSInteger idx;
    do {
        self.esi = (self.esi + lcgConst) & 0xFFFFFFFF;
        self.esi = ((self.esi >> 1) | (self.esi << 31)) & 0xFFFFFFFF;
        idx = self.esi & 0xFFFF;
    } while (idx >= kTotalPixels);

    uint8_t px = self.imageBuffer[idx];
    if (px == 0) {
        return;
    }

    // Dim the pixel by one
    self.imageBuffer[idx] = --px;

    if (px >= kSpreadThreshold) {
        // Spread to Von Neumann neighbors
        NSInteger right = idx + 1;
        if (right < kTotalPixels) {
            if (self.imageBuffer[right] == 0) self.imageBuffer[right] = kMaxBrightness;
        }

        NSInteger left = idx - 1;
        if (left >= 0) {
            if (self.imageBuffer[left] == 0) self.imageBuffer[left] = kMaxBrightness;
        }

        NSInteger down = idx + kWidth;
        if (down < kTotalPixels) {
            if (self.imageBuffer[down] == 0) self.imageBuffer[down] = kMaxBrightness;
        }

        NSInteger up = idx - kWidth;
        if (up >= 0) {
            if (self.imageBuffer[up] == 0) self.imageBuffer[up] = kMaxBrightness;
        }
    }
}

- (void)updateRenderedImage {
    if (!self.bitmap) {
        self.bitmap = [[NSBitmapImageRep alloc]
            initWithBitmapDataPlanes:NULL
                          pixelsWide:kWidth
                          pixelsHigh:kHeight
                       bitsPerSample:8
                     samplesPerPixel:1
                            hasAlpha:NO
                            isPlanar:NO
                      colorSpaceName:NSDeviceWhiteColorSpace
                         bytesPerRow:kWidth
                        bitsPerPixel:8];
    }

    uint8_t *bitmapData = [self.bitmap bitmapData];
    const uint8_t *src = self.imageBuffer;

    // Copy and scale brightness in a single pass
    for (NSInteger i = 0; i < kTotalPixels; i++) {
        uint8_t val = src[i];
        bitmapData[i] = val ? (uint8_t)((val * 255) / kMaxBrightness) : 0;
    }

    // Reuse existing NSImage or create once
    if (!self.renderedImage) {
        NSSize bitmapSize = NSMakeSize(kWidth, kHeight);
        self.renderedImage = [[NSImage alloc] initWithSize:bitmapSize];
        [self.renderedImage addRepresentation:self.bitmap];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor blackColor] setFill];
    NSRectFill(dirtyRect);

    if (!self.renderedImage) { return; }

    // Fill entire screen (stretch to fit).
    // Handles the extra pixels on mac devices with a notch
    NSRect destRect = self.bounds;

    // Draw with nearest-neighbor interpolation (no smoothing)
    [NSGraphicsContext saveGraphicsState];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
    [self.renderedImage drawInRect:destRect
                          fromRect:NSZeroRect
                         operation:NSCompositingOperationSourceOver
                          fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];

    [SSKDiagnostics drawOverlayInView:self
                                text:@"Lichen"
                     framesPerSecond:self.animationClock.framesPerSecond];
}

@end
