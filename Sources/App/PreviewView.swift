//
//  PreviewView.swift
//  Lichen
//
//  Vendored from AppexSaverMinimal (https://github.com/AerialScreensaver/AppexSaverMinimal).
//
//  NSView that runs the same LichenAnimator the screensaver extension uses, so
//  the host app's Preview window matches what the screensaver displays. The host
//  app runs a normal main run loop, so a plain Timer drives the cadence here
//  (the appex itself uses the framework animation timer -- see LichenSaverView).
//

import AppKit

final class PreviewView: NSView {

    private let animator = LichenAnimator()
    private var timer: Timer?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }

    override var wantsUpdateLayer: Bool { true }

    override func makeBackingLayer() -> CALayer {
        let layer = CALayer()
        layer.backgroundColor = animator.currentBackgroundColor.cgColor
        layer.isOpaque = true
        layer.magnificationFilter = .nearest
        layer.contentsGravity = .resize
        return layer
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window != nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
                guard let self else { return }
                self.animator.advance()
                self.needsDisplay = true
            }
        } else {
            timer?.invalidate()
            timer = nil
        }
    }

    override func updateLayer() {
        layer?.contents = animator.makeImage()
    }

    deinit {
        timer?.invalidate()
    }
}
