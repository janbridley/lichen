//
//  LichenExtension.swift
//  LichenExtension
//
//  Vendored from AppexSaverMinimal (https://github.com/AerialScreensaver/AppexSaverMinimal).
//
//  Principal class for the screensaver extension. Specified as
//  NSExtensionPrincipalClass in Info.plist as `$(PRODUCT_MODULE_NAME).LichenExtension`.
//  Mirrors Apple's Arabesque.appex: only implement init() and let the framework
//  drive the lifecycle.
//

import Foundation
import ScreenSaver

@objc(LichenExtension)
class LichenExtension: ScreenSaverExtension {

    @objc override init() {
        super.init()
    }
}
