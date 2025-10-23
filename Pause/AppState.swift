//
//  AppState.swift
//  Pause
//
//  Created by Harrison Qian on 10/22/25.
//

import SwiftUI
import AppKit
import AVFoundation

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var isPauseMode: Bool = false
    @Published var timeRemaining: Int = 60
    @Published var messageCount: Int = 0

    var timer: Timer?
    var audioPlayer: AVAudioPlayer?
    var eventMonitor: Any?
    var createdWindows: [NSWindow] = []  // Keep strong references to windows we create

    // Available ambient sound files
    let ambientSounds = [
        "pad_uplifting",
        "pad2",
        "keys",
        "rain",
        "walking"
    ]

    private init() {}

    func triggerPauseMode() {
        if isPauseMode {
            // If already in pause mode, exit it
            endPauseMode()
        } else {
            // Enter pause mode
            startPauseMode()
        }
    }

    func startPauseMode() {
        messageCount += 1
        isPauseMode = true
        timeRemaining = 60

        // Ensure a window exists and go fullscreen
        ensureWindowAndFullscreen()

        // Start playing a random ambient sound
        playRandomAmbientSound()

        // Start the countdown timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endPauseMode()
            }
        }

        // Add event monitor for spacebar
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 49 { // 49 is the key code for spacebar
                self.endPauseMode()
                return nil // Consume the event
            }
            return event
        }
    }

    func endPauseMode() {
        // Stop the timer
        timer?.invalidate()
        timer = nil

        // Stop the audio player
        audioPlayer?.stop()
        audioPlayer = nil

        // Remove event monitor
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }

        // Exit fullscreen
        exitFullscreen()

        // Exit pause mode
        isPauseMode = false
    }

    private func ensureWindowAndFullscreen() {
        // Activate the app first
        NSApp.activate(ignoringOtherApps: true)

        // Find or create a window
        var window: NSWindow?

        // First try to find a visible window
        window = NSApplication.shared.windows.first { $0.isVisible && $0.isKeyWindow == false || $0.isKeyWindow }

        if window == nil {
            // Try to find any app window (not including system windows)
            window = NSApplication.shared.windows.first { window in
                // Filter out system windows
                return window.className.contains("SwiftUI") || window.title == "Pause" || window.contentView != nil
            }
        }

        if window == nil {
            // No window exists, create one manually
            let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            newWindow.center()
            newWindow.title = "Pause"
            newWindow.setFrameAutosaveName("Main Window")
            newWindow.isReleasedWhenClosed = false  // Keep window alive when closed

            // Create ContentView with shared state
            newWindow.contentView = NSHostingView(rootView: ContentView())

            // Keep a strong reference to the window
            createdWindows.append(newWindow)

            // Set up notification to remove window from array when it closes
            NotificationCenter.default.addObserver(
                forName: NSWindow.willCloseNotification,
                object: newWindow,
                queue: .main
            ) { [weak self] notification in
                if let closedWindow = notification.object as? NSWindow {
                    self?.createdWindows.removeAll { $0 === closedWindow }
                }
            }

            newWindow.makeKeyAndOrderFront(nil)

            // Wait for the window to be ready, then go fullscreen
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                newWindow.toggleFullScreen(nil)
            }
            return
        }

        // Make sure window is visible and key
        window?.makeKeyAndOrderFront(nil)
        window?.orderFrontRegardless()

        let isCurrentlyFullscreen = window?.styleMask.contains(.fullScreen) ?? false

        if !isCurrentlyFullscreen {
            window?.toggleFullScreen(nil)
        }
    }

    private func exitFullscreen() {
        // Find the window and exit fullscreen
        guard let window = NSApplication.shared.windows.first(where: { $0.isVisible }) else { return }

        let isCurrentlyFullscreen = window.styleMask.contains(.fullScreen)

        if isCurrentlyFullscreen {
            window.toggleFullScreen(nil)
        }
    }

    private func playRandomAmbientSound() {
        // Select a random ambient sound
        guard let randomSound = ambientSounds.randomElement() else { return }

        // Get the URL for the sound file (Xcode copies them to the main bundle Resources)
        guard let soundURL = Bundle.main.url(forResource: randomSound, withExtension: "mp3") else {
            print("Could not find audio file: \(randomSound).mp3")
            return
        }

        do {
            // Create and configure audio player
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = 0.5 // Set volume to 50%
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

            print("Playing ambient sound: \(randomSound).mp3")
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
}
