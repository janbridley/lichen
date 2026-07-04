//
//  Logger.swift
//  Lichen
//
//  Lichen-owned override of AppexSaverMinimal's Logger: only the subsystem
//  string changes. The `AppexLog` type name is preserved because the (lichen-owned
//  and submodule-verbatim) views reference it.
//

import Foundation
import os.log

/// Logging configuration shared between the host app and the screensaver extension.
///
/// Open Console.app and filter by subsystem `com.janbridley.lichen` to see logs
/// from the host app and the appex extension at the same time. Each entry's
/// category and PID identify which process produced the line.
enum AppexLog {
    static let subsystem = "com.janbridley.lichen"

    static func logger(_ category: String) -> Logger {
        Logger(subsystem: subsystem, category: category)
    }
}
