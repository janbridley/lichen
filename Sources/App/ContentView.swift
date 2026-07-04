//
//  ContentView.swift
//  Lichen
//
//  Minimal host UI: register the appex (Install) and activate it as the system
//  screensaver (Enable, via PaperSaverKit). Kept small for testing activation.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow
    @StateObject private var plugin = PluginManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("Lichen")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(plugin.status)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 320)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                Button("Install") { plugin.install() }
                    .buttonStyle(.bordered)

                Button("Enable as Screensaver") {
                    Task { await plugin.enable() }
                }
                .buttonStyle(.borderedProminent)

                Button("Open Preview") { openWindow(id: "preview") }
                    .buttonStyle(.bordered)
            }
        }
        .padding(40)
        .fixedSize()
    }
}
