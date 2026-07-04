//
//  LichenViewController.swift
//  LichenExtension
//
//  Vendored from AppexSaverMinimal (https://github.com/AerialScreensaver/AppexSaverMinimal).
//
//  Main view controller for the screensaver. Specified as
//  ScreenSaverViewControllerClass in Info.plist as
//  `$(PRODUCT_MODULE_NAME).LichenViewController`. Only overrides the standard
//  inits and loadView(); the framework drives everything else.
//

import AppKit
import ScreenSaver

@objc(LichenViewController)
class LichenViewController: ScreenSaverViewController {

    /// Strong reference so the framework can't drop our view while we still own it.
    private var saverView: LichenSaverView?

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// Called by the framework to create the view.
    override func loadView() {
        let frame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
        let isPreview = frame.width < 400

        let view = LichenSaverView(frame: frame, isPreview: isPreview)
        saverView = view
        self.view = view ?? NSView(frame: frame)
    }
}
