//
//  LichenApp.swift
//  Lichen
//
//  Host application. Embeds the LichenExtension.appex, provides a minimal
//  install/enable UI, and a preview window.
//

import SwiftUI

@main
struct LichenApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        Window("Preview", id: "preview") {
            PreviewViewRepresentable()
                .ignoresSafeArea()
        }
        .defaultSize(width: 640, height: 480)
    }
}
