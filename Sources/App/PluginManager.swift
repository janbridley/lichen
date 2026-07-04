//
//  PluginManager.swift
//  Lichen
//
//  Minimal install + activation helper. Restored (without logging) to test
//  whether activating Lichen as the system screensaver via PaperSaverKit is
//  what made it render at 4547c70 (vs. falling back to the Tahoe default).
//

import Foundation
import PaperSaverKit

@MainActor
final class PluginManager: ObservableObject {

    @Published var status = "Ready"
    @Published var isActive = false

    private let paperSaver = PaperSaver()
    // PaperSaver identifies a screensaver module by its appex product name
    // (CFBundleName); the appex's PRODUCT_NAME is LichenExtension.
    private let moduleName = "LichenExtension"

    private var embeddedExtensionPath: String? {
        Bundle.main.builtInPlugInsURL?.appendingPathComponent("LichenExtension.appex").path
    }

    /// Register the embedded appex with macOS via pluginkit.
    func install() {
        guard let path = embeddedExtensionPath,
              FileManager.default.fileExists(atPath: path) else {
            status = "Embedded appex not found in app bundle"
            return
        }
        do {
            _ = try runProcess("/usr/bin/pluginkit", arguments: ["-a", path])
            status = "Registered. Tap Enable."
        } catch {
            status = "Install failed: \(error.localizedDescription)"
        }
    }

    /// Set Lichen as the active screensaver on every display.
    func enable() async {
        do {
            try await paperSaver.setScreensaverEverywhere(module: moduleName)
            isActive = paperSaver.getActiveScreensavers().contains(moduleName)
            status = isActive
                ? "Active — trigger with: open -a ScreenSaverEngine"
                : "Enabled, but not detected as active"
        } catch {
            status = "Enable failed: \(error.localizedDescription)"
        }
    }

    private func runProcess(_ path: String, arguments: [String]) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        process.waitUntilExit()
        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    }
}
