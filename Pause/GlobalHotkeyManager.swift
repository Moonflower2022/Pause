//
//  GlobalHotkeyManager.swift
//  Pause
//
//  Created by Harrison Qian on 10/22/25.
//

import SwiftUI
import Carbon.HIToolbox

class GlobalHotkeyManager: ObservableObject {
    static let shared = GlobalHotkeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    var onHotkeyPressed: (() -> Void)?

    private init() {
        setupHotkey()

        // Listen for settings changes to re-register hotkey
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // Re-register hotkey when settings change
            self?.reregisterHotkey()
        }
    }

    deinit {
        cleanup()
    }

    private func setupHotkey() {
        // Define the hotkey signature and ID
        let hotKeyID = EventHotKeyID(signature: OSType(0x48545359), id: 1) // 'HTSY' signature

        // Get hotkey settings from Settings
        let settings = Settings.shared
        let keyCode = settings.hotkeyKeyCode
        let modifiers = settings.hotkeyModifiers

        // Event type specification
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))

        // Install event handler
        InstallEventHandler(GetApplicationEventTarget(), { (_, inEvent, userData) -> OSStatus in
            guard let userData = userData else { return OSStatus(eventNotHandledErr) }

            // Get the hotkey manager instance
            let manager = Unmanaged<GlobalHotkeyManager>.fromOpaque(userData).takeUnretainedValue()

            // Call the callback on the main thread
            DispatchQueue.main.async {
                manager.onHotkeyPressed?()
            }

            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)

        // Register the hotkey
        // Note: RegisterEventHotKey requires an inout parameter, so we need a var copy
        var hotKeyIDCopy = hotKeyID
        let status = RegisterEventHotKey(keyCode,
                                        modifiers,
                                        hotKeyIDCopy,
                                        GetApplicationEventTarget(),
                                        0,
                                        &hotKeyRef)

        if status != noErr {
            print("Failed to register global hotkey: \(status)")
        } else {
            print("Global hotkey registered successfully: \(Settings.shared.getHotkeyString())")
        }
    }

    // Re-register hotkey with new settings
    func reregisterHotkey() {
        cleanup()
        setupHotkey()
    }

    private func cleanup() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }
}
