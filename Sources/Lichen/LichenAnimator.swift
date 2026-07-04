//
//  LichenAnimator.swift
//  Lichen
//
//  Faithful Swift port of the legacy Lichen/LichenView.m cellular automaton
//  (itself derived from the MS-DOS "lichen" program). A 320x200 grid of 8-bit
//  brightness cells; each step an LCG picks one cell, dims it, and -- if it is
//  still bright enough -- seeds its four Von Neumann neighbors. The grid is
//  rendered to a grayscale CGImage and set as the host CALayer's `contents`;
//  the layer's nearest-neighbor magnification (configured in attach(to:))
//  upscales it to the display via the Core Animation compositor, exactly as the
//  legacy .saver did. No Metal.
//
//  Exposes a small seam (currentBackgroundColor / attach / start / stop /
//  updateBounds) that LichenSaverView (the appex) and PreviewView (the host
//  app) drive.
//

import AppKit
import QuartzCore

private enum LichenConfig {
    static let width: Int = 320
    static let height: Int = 200
    static let totalPixels: Int = width * height          // 64000
    static let maxBrightness: UInt8 = 0x1E                 // 30 -- spore brightness
    static let spreadThreshold: UInt8 = 0x17               // 23 -- minimum brightness to spread
    static let lcgConst: UInt32 = 0x5A6A6D6C
    static let lcgSeed: UInt32 = 0x00000361
    static let stepsPerFrame: Int = 4000
    static let frameInterval: TimeInterval = 1.0 / 60.0
}

final class LichenAnimator {

    // MARK: Simulation state
    private var buffer: [UInt8]            // brightness 0..maxBrightness per cell
    private var bitmapData: [UInt8]        // scaled 0..255 grayscale per cell
    private var esi: UInt32 = LichenConfig.lcgSeed

    // MARK: Rendering
    private weak var parentLayer: CALayer?
    private var timer: Timer?
    // Device gray matches the legacy NSDeviceWhiteColorSpace used by LichenView.m.
    private let colorSpace = CGColorSpaceCreateDeviceGray()

    // MARK: Seam (matches RainbowAnimator)

    /// Used by the view's `makeBackingLayer()` to set the initial background color.
    var currentBackgroundColor: NSColor { .black }

    init() {
        buffer = [UInt8](repeating: 0, count: LichenConfig.totalPixels)
        bitmapData = [UInt8](repeating: 0, count: LichenConfig.totalPixels)
        // Place the initial spore at the center, matching LichenView.m.
        let centerX = LichenConfig.width / 2
        let centerY = LichenConfig.height / 2
        buffer[centerY * LichenConfig.width + centerX] = LichenConfig.maxBrightness
    }

    func attach(to layer: CALayer) {
        parentLayer = layer
        layer.backgroundColor = NSColor.black.cgColor
        layer.isOpaque = true
        // Nearest-neighbor upscale to match the original low-res layout.
        layer.magnificationFilter = .nearest
        layer.contentsGravity = .resize
    }

    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: LichenConfig.frameInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func updateBounds(_ bounds: CGRect) {
        // contentsGravity = .resize handles scaling; nothing else to do.
    }

    // MARK: Per-frame

    private func tick() {
        for _ in 0..<LichenConfig.stepsPerFrame {
            processOneStep()
        }
        parentLayer?.contents = currentImage()
    }

    /// One stochastic single-pixel update, faithful to LichenView.m.
    private func processOneStep() {
        let total = LichenConfig.totalPixels
        let width = LichenConfig.width

        var idx: Int
        repeat {
            // LCG: add the magic constant (wrapping), then rotate right by 1.
            esi = esi &+ LichenConfig.lcgConst
            esi = (esi >> 1) | (esi << 31)
            idx = Int(esi & 0xFFFF)
        } while idx >= total

        var px = buffer[idx]
        if px == 0 { return }

        // Dim the pixel by one, then spread if it is still bright enough.
        px -= 1
        buffer[idx] = px

        guard px >= LichenConfig.spreadThreshold else { return }

        // Seed the four Von Neumann neighbors (no wrap, bounds-checked). A
        // neighbor is seeded only if it is currently empty (0). This mirrors
        // LichenView.m, including that left/right are not row-aware.
        let right = idx + 1
        if right < total && buffer[right] == 0 { buffer[right] = LichenConfig.maxBrightness }

        let left = idx - 1
        if left >= 0 && buffer[left] == 0 { buffer[left] = LichenConfig.maxBrightness }

        let down = idx + width
        if down < total && buffer[down] == 0 { buffer[down] = LichenConfig.maxBrightness }

        let up = idx - width
        if up >= 0 && buffer[up] == 0 { buffer[up] = LichenConfig.maxBrightness }
    }

    /// Build a 320x200 8-bit grayscale CGImage from the simulation buffer.
    private func currentImage() -> CGImage? {
        let maxValue = Int(LichenConfig.maxBrightness)
        for i in 0..<LichenConfig.totalPixels {
            let v = Int(buffer[i])
            bitmapData[i] = v == 0 ? 0 : UInt8((v * 255) / maxValue)
        }

        let width = LichenConfig.width
        let height = LichenConfig.height

        // NSData(bytes:length:) copies the bytes, so the returned CGImage owns
        // its data independently of `bitmapData`.
        return bitmapData.withUnsafeBufferPointer { ptr -> CGImage? in
            guard let base = ptr.baseAddress else { return nil }
            let data = NSData(bytes: base, length: bitmapData.count)
            guard let provider = CGDataProvider(data: data) else { return nil }
            return CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 8,
                bytesPerRow: width,
                space: colorSpace,
                bitmapInfo: CGBitmapInfo(rawValue: 0),
                provider: provider,
                decode: nil,
                shouldInterpolate: false,
                intent: .defaultIntent
            )
        }
    }
}
