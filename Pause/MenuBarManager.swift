//
//  MenuBarManager.swift
//  Pause
//
//  Created by Harrison Qian on 10/22/25.
//

import SwiftUI
import AppKit

class MenuBarManager: ObservableObject {
    static let shared = MenuBarManager()

    private var statusItem: NSStatusItem?
    private var isShowing = false
    private var updateTimer: Timer?

    private init() {
        // Subscribe to settings changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsChanged),
            name: NSNotification.Name("SettingsChanged"),
            object: nil
        )

        // Initialize based on current setting
        updateMenuBarVisibility()
    }

    @objc private func settingsChanged() {
        updateMenuBarVisibility()
    }

    func updateMenuBarVisibility() {
        let shouldShow = Settings.shared.showInMenuBar

        if shouldShow && !isShowing {
            showMenuBar()
        } else if !shouldShow && isShowing {
            hideMenuBar()
        }
    }

    private func showMenuBar() {
        guard statusItem == nil else { return }

        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.action = #selector(menuBarIconClicked)
            button.target = self
        }

        // Start updating the countdown
        updateCountdown()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCountdown()
        }

        // Create menu
        let menu = NSMenu()

        // Start Session menu item
        let startItem = NSMenuItem(
            title: "Start Session",
            action: #selector(startSession),
            keyEquivalent: ""
        )
        startItem.target = self
        menu.addItem(startItem)

        menu.addItem(NSMenuItem.separator())

        // Show Settings menu item
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(showSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        // Quit menu item
        let quitItem = NSMenuItem(
            title: "Quit Pause",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
        isShowing = true
    }

    private func hideMenuBar() {
        updateTimer?.invalidate()
        updateTimer = nil

        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
            isShowing = false
        }
    }

    func updateCountdown() {
        guard let button = statusItem?.button else { return }

        let showTimer = Settings.shared.menuBarShowTimer

        if showTimer, let nextActivation = getNextActivation() {
            // Show countdown timer
            let timeRemaining = max(0, nextActivation.date.timeIntervalSinceNow)

            // If timer hits 0:00, recalculate all timers
            if timeRemaining <= 0 {
                print("Timer reached 0:00 - recalculating all timers")
                ActivationScheduler.shared.recalculateTimers()
            }

            let countdownText = formatCountdown(timeRemaining)
            button.title = countdownText
            button.image = nil
        } else {
            // Show icon
            button.title = ""
            let image = NSImage(systemSymbolName: "pause.circle", accessibilityDescription: "Pause")
            image?.isTemplate = true
            button.image = image
        }
    }

    private func getNextActivation() -> (date: Date, type: String)? {
        let scheduler = ActivationScheduler.shared
        var soonest: (date: Date, type: String)?

        // Check repeated timer
        if let repeatedDate = scheduler.nextRepeatedActivation {
            soonest = (repeatedDate, "Repeated")
        }

        // Check random timer
        if let randomDate = scheduler.nextRandomActivation {
            if let current = soonest {
                if randomDate < current.date {
                    soonest = (randomDate, "Random")
                }
            } else {
                soonest = (randomDate, "Random")
            }
        }

        // Check scheduled timer
        if let scheduledDate = scheduler.nextScheduledActivation {
            if let current = soonest {
                if scheduledDate < current.date {
                    soonest = (scheduledDate, "Scheduled")
                }
            } else {
                soonest = (scheduledDate, "Scheduled")
            }
        }

        return soonest
    }

    private func formatCountdown(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else if minutes > 0 {
            return String(format: "%d:%02d", minutes, secs)
        } else {
            return String(format: "0:%02d", secs)
        }
    }

    @objc private func menuBarIconClicked() {
        // This is called when the icon is clicked
        // The menu will show automatically
    }

    @objc private func startSession() {
        AppState.shared.triggerPauseMode()
    }

    @objc private func showSettings() {
        // Activate the app
        NSApp.activate(ignoringOtherApps: true)

        // First check if we have a settings window in our created windows
        let settingsWindow = AppState.shared.createdWindows.first { window in
            // Look for normal titled windows that aren't fullscreen
            window.styleMask.contains(.titled) &&
            !window.styleMask.contains(.borderless) &&
            !window.styleMask.contains(.fullScreen)
        }

        if let window = settingsWindow {
            // Window exists, just bring it to front
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
        } else {
            // Check if there's a window in NSApp.windows (from WindowGroup)
            let mainWindow = NSApp.windows.first { window in
                window.styleMask.contains(.titled) &&
                !window.styleMask.contains(.borderless) &&
                !window.styleMask.contains(.fullScreen) &&
                window.contentView is NSHostingView<ContentView>
            }

            if let window = mainWindow {
                // Window exists, just bring it to front
                window.makeKeyAndOrderFront(nil)
                window.orderFrontRegardless()

                // Add to created windows for future reuse
                if !AppState.shared.createdWindows.contains(where: { $0 === window }) {
                    AppState.shared.createdWindows.append(window)
                }
            } else {
                // No window exists, create a new one
                let contentView = ContentView()
                let window = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: 600, height: 550),
                    styleMask: [.titled, .closable, .miniaturizable, .resizable],
                    backing: .buffered,
                    defer: false
                )
                window.center()
                window.isReleasedWhenClosed = false  // Keep window alive when closed
                window.contentView = NSHostingView(rootView: contentView)
                window.title = "Pause"
                window.makeKeyAndOrderFront(nil)

                // Keep a strong reference to prevent deallocation
                AppState.shared.createdWindows.append(window)
            }
        }
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
