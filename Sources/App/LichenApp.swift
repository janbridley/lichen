//
//  LichenApp.swift
//  Lichen
//
//  Vendored from AppexSaverMinimal (https://github.com/AerialScreensaver/AppexSaverMinimal).
//
//  Host application. Its only job is to embed the LichenExtension.appex (so macOS
//  can discover the screensaver) and show a preview window. Drop Lichen.app into
//  /Applications and the screensaver appears in System Settings automatically.
//

import SwiftUI

@main
struct LichenApp: App {
    var body: some Scene {
        WindowGroup {
            PreviewViewRepresentable()
                .ignoresSafeArea()
        }
        .defaultSize(width: 640, height: 480)
    }
}
