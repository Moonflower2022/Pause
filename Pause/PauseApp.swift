//
//  PauseApp.swift
//  Pause
//
//  Created by Harrison Qian on 10/22/25.
//

import SwiftUI

@main
struct PauseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        // Set up global hotkey callback on app launch
        GlobalHotkeyManager.shared.onHotkeyPressed = {
            AppState.shared.triggerPauseMode()
        }

        // Initialize the activation scheduler
        _ = ActivationScheduler.shared

        // Initialize the menu bar manager
        _ = MenuBarManager.shared

        // Initialize the input detection manager
        _ = InputDetectionManager.shared

        // Initialize Sparkle updater
        _ = SparkleUpdater.shared

        // Initialize app launch monitor
        _ = AppLaunchMonitor.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Pause") {
                    NSApplication.shared.orderFrontStandardAboutPanel()
                }
            }

            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    SparkleUpdater.shared.checkForUpdates()
                }
                Divider()
            }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 600, height: 550)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep the app running even when all windows are closed
        // This allows the global hotkey to work when no window is open
        return false
    }
}
