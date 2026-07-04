//
//  AppexSaverMinimalView.swift
//  LichenExtension
//
//  Lichen-owned override of AppexSaverMinimal's ScreenSaverView: identical except
//  it runs the LichenAnimator (the cellular automaton) instead of RainbowAnimator.
//  The class name is kept (AppexSaverMinimalView) so the submodule-verbatim
//  AppexSaverMinimalViewController resolves it without modification.
//

import ScreenSaver
import QuartzCore

private let logger = AppexLog.logger("View")

final class AppexSaverMinimalView: ScreenSaverView {

    private let animator = LichenAnimator()

    override init?(frame: NSRect, isPreview: Bool) {
        logger.info("init(frame: \(frame.size.width, privacy: .public)x\(frame.size.height, privacy: .public), isPreview: \(isPreview))")
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
        logger.info("deinit")
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
    // These are called by the framework. We rely on viewDidMoveToWindow to
    // start/stop the animator (which is robust across both ScreenSaverEngine
    // and System Settings preview), but the overrides remain so the framework
    // can drive them if it wants to.

    override func startAnimation() {
        logger.info("startAnimation()")
        super.startAnimation()
        animator.start()
    }

    override func stopAnimation() {
        logger.info("stopAnimation()")
        animator.stop()
        super.stopAnimation()
    }

    // MARK: - View Lifecycle

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        logger.info("viewDidMoveToWindow() hasWindow=\(self.window != nil)")

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
