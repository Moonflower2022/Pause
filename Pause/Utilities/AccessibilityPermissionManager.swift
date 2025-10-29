//
//  AccessibilityPermissionManager.swift
//  Pause
//
//  Tracks macOS accessibility trust status for Pause
//

import ApplicationServices
import Combine

final class AccessibilityPermissionManager: ObservableObject {
    static let shared = AccessibilityPermissionManager()

    @Published private(set) var hasAccessibilityPermission: Bool = false

    private init() {
        refreshStatus()
    }

    func refreshStatus(promptIfNeeded: Bool = false) {
        if promptIfNeeded {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
            hasAccessibilityPermission = AXIsProcessTrustedWithOptions(options)
            return
        }

        hasAccessibilityPermission = AXIsProcessTrusted()
    }
}
