//
//  LichenSaverView.swift
//  LichenExtension
//
//  Vendored from AppexSaverMinimal (https://github.com/AerialScreensaver/AppexSaverMinimal).
//
//  ScreenSaverView that displays the lichen cellular automaton. The animation
//  logic lives in LichenAnimator (shared with the host app's PreviewView).
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

    deinit {
        animator.stop()
    }

    // MARK: - Layer Setup

    override func makeBackingLayer() -> CALayer {
        let layer = CALayer()
        layer.backgroundColor = animator.currentBackgroundColor.cgColor
        layer.isOpaque = true
        return layer
    }

    // MARK: - ScreenSaverView Overrides
    //
    // We rely on viewDidMoveToWindow to start/stop the animator (robust across
    // both ScreenSaverEngine and the System Settings preview), but the overrides
    // remain so the framework can drive them if it wants to.

    override func startAnimation() {
        super.startAnimation()
        animator.start()
    }

    override func stopAnimation() {
        animator.stop()
        super.stopAnimation()
    }

    // MARK: - View Lifecycle

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        if self.window != nil {
            if let layer = self.layer {
                animator.attach(to: layer)
                animator.updateBounds(bounds)
            }
            animator.start()
        } else {
            animator.stop()
        }
    }

    override func layout() {
        super.layout()
        animator.updateBounds(bounds)
    }
}
