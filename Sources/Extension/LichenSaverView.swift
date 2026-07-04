//
//  LichenSaverView.swift
//  LichenExtension
//
//  Vendored from AppexSaverMinimal (https://github.com/AerialScreensaver/AppexSaverMinimal).
//
//  ScreenSaverView that displays the lichen cellular automaton. Uses the
//  traditional ScreenSaverView overrides (animateOneFrame + updateLayer) with
//  SSENeedsAnimationTimer = true, so the ScreenSaverEngine framework drives the
//  per-frame cadence itself. This is the reliable path for per-frame content in
//  the appex host -- a self-driven Timer does not fire reliably there, and unlike
//  a CABasicAnimation (render-server-interpolated) lichen needs a real tick each
//  frame to rebuild layer.contents. The simulation + image build live in
//  LichenAnimator (shared with the host app's PreviewView).
//

import ScreenSaver
import QuartzCore

final class LichenSaverView: ScreenSaverView {

    private let animator = LichenAnimator()

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        wantsLayer = true
        animationTimeInterval = 1.0 / 60.0
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }

    // Layer-backed: AppKit calls updateLayer() instead of draw(_:) to repaint.
    override var wantsUpdateLayer: Bool { true }

    override func makeBackingLayer() -> CALayer {
        let layer = CALayer()
        layer.backgroundColor = animator.currentBackgroundColor.cgColor
        layer.isOpaque = true
        layer.magnificationFilter = .nearest   // chunky-pixel upscale to the display
        layer.contentsGravity = .resize
        return layer
    }

    // Called by the framework's animation timer (SSENeedsAnimationTimer = true).
    override func animateOneFrame() {
        animator.advance()
        needsDisplay = true
    }

    override func updateLayer() {
        layer?.contents = animator.makeImage()
    }
}
