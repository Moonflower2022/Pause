//
//  SparkleUpdater.swift
//  Pause
//
//  Manages automatic updates using Sparkle framework
//

import Foundation
import AppKit

// Temporary: Comment out Sparkle until package is fully integrated
#if canImport(Sparkle)
import Sparkle

class SparkleUpdater: ObservableObject {
    static let shared = SparkleUpdater()

    private let updaterController: SPUStandardUpdaterController

    private init() {
        // Initialize Sparkle updater
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }

    /// Check for updates manually (for "Check for Updates..." menu item)
    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }

    /// Get the updater controller (for binding to SwiftUI)
    var updater: SPUUpdater {
        return updaterController.updater
    }

    /// Check if automatic update checking is enabled
    var automaticallyChecksForUpdates: Bool {
        get {
            return updaterController.updater.automaticallyChecksForUpdates
        }
        set {
            updaterController.updater.automaticallyChecksForUpdates = newValue
        }
    }

    /// Get/set the update check interval (in seconds)
    var updateCheckInterval: TimeInterval {
        get {
            return updaterController.updater.updateCheckInterval
        }
        set {
            updaterController.updater.updateCheckInterval = newValue
        }
    }
}
#else
// Stub implementation when Sparkle is not available
class SparkleUpdater: ObservableObject {
    static let shared = SparkleUpdater()

    private init() {
        print("⚠️ Sparkle not available - update checking disabled")
    }

    func checkForUpdates() {
        print("⚠️ Sparkle not available - cannot check for updates")
        // Show alert to user
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Updates Not Available"
            alert.informativeText = "Update checking is not configured yet. Please complete Sparkle setup in Xcode."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}
#endif
