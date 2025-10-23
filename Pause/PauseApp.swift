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
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep the app running even when all windows are closed
        // This allows the global hotkey to work when no window is open
        return false
    }
}
