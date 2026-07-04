//  LichenApp.swift
//  Lichen
//
//  Host application. Embeds the LichenExtension.appex with a minimal install UI.

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
