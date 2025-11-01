//
//  InputLockManager.swift
//  Pause
//
//  Manages input blocking during meditation sessions using accessibility permissions
//

import Foundation
import ApplicationServices
import Combine

class InputLockManager: ObservableObject {
    static let shared = InputLockManager()

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var permissionCheckTimer: Timer?

    // Published properties that update automatically
    @Published var hasAccessibilityPermission: Bool = false
    @Published var hasInputMonitoringPermission: Bool = false

    private init() {
        // Initial check
        updatePermissions()

        // Monitor accessibility permission changes via distributed notification
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(accessibilityChanged),
            name: NSNotification.Name("com.apple.accessibility.api"),
            object: nil
        )

        // Poll for input monitoring permission changes (no notification available)
        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updatePermissions()
        }
    }

    @objc private func accessibilityChanged() {
        // Delay slightly as permission changes take time to propagate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.updatePermissions()
        }
    }

    private func updatePermissions() {
        let newAccessibility = AXIsProcessTrusted()
        let newInputMonitoring = CGPreflightListenEventAccess()

        if newAccessibility != hasAccessibilityPermission {
            DispatchQueue.main.async {
                self.hasAccessibilityPermission = newAccessibility
            }
        }

        if newInputMonitoring != hasInputMonitoringPermission {
            DispatchQueue.main.async {
                self.hasInputMonitoringPermission = newInputMonitoring
            }
        }
    }

    // Check if the app has both permissions needed for input blocking
    func hasAllPermissions() -> Bool {
        let hasAccessibility = hasAccessibilityPermission
        let hasInputMonitoring = hasInputMonitoringPermission

        if !hasAccessibility {
            print("⚠️ Missing Accessibility permission")
        }
        if !hasInputMonitoring {
            print("⚠️ Missing Input Monitoring permission")
        }

        // Both are required: Accessibility for event tap creation, Input Monitoring for blocking
        return hasAccessibility && hasInputMonitoring
    }

    // Request accessibility permission (opens System Settings)
    func requestAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options)
    }

    // Request input monitoring permission (opens System Settings)
    func requestInputMonitoringPermission() {
        CGRequestListenEventAccess()
    }

    // Start blocking input events
    func startBlocking() {
        // If already blocking, don't create another tap
        guard eventTap == nil else { return }

        // Check permissions first
        guard hasAllPermissions() else {
            print("⚠️ Missing required permissions - cannot block input")
            return
        }

        // Event mask for keyboard and mouse events
        // Build mask in parts to avoid compiler timeout
        var eventMask: CGEventMask = 0

        // Keyboard events
        eventMask |= (1 << CGEventType.keyDown.rawValue)
        eventMask |= (1 << CGEventType.keyUp.rawValue)
        eventMask |= (1 << CGEventType.flagsChanged.rawValue)

        // Mouse button events
        eventMask |= (1 << CGEventType.leftMouseDown.rawValue)
        eventMask |= (1 << CGEventType.leftMouseUp.rawValue)
        eventMask |= (1 << CGEventType.rightMouseDown.rawValue)
        eventMask |= (1 << CGEventType.rightMouseUp.rawValue)
        eventMask |= (1 << CGEventType.otherMouseDown.rawValue)
        eventMask |= (1 << CGEventType.otherMouseUp.rawValue)

        // Mouse movement events
        eventMask |= (1 << CGEventType.mouseMoved.rawValue)
        eventMask |= (1 << CGEventType.leftMouseDragged.rawValue)
        eventMask |= (1 << CGEventType.rightMouseDragged.rawValue)
        eventMask |= (1 << CGEventType.otherMouseDragged.rawValue)
        eventMask |= (1 << CGEventType.scrollWheel.rawValue)

        // Create event tap callback
        let callback: CGEventTapCallBack = { proxy, type, event, refcon in
            // Get self reference
            let manager = Unmanaged<InputLockManager>.fromOpaque(refcon!).takeUnretainedValue()

            // Check if the tap was disabled (happens when accessibility is revoked)
            if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                print("⚠️ Event tap disabled - re-enabling")
                if let tap = manager.eventTap {
                    CGEvent.tapEnable(tap: tap, enable: true)
                }
                return Unmanaged.passUnretained(event)
            }

            // Log that we're blocking an event (for debugging)
            print("🚫 Blocking event: \(type.rawValue)")

            // Block the event by returning nil
            return nil
        }

        // Create the event tap at session level
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: callback,
            userInfo: selfPtr
        )

        guard let eventTap = eventTap else {
            print("❌ Failed to create event tap - check accessibility permissions")
            return
        }

        // Create a run loop source and add it to the main run loop
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)

        if let runLoopSource = runLoopSource {
            // IMPORTANT: Add to main run loop, not current
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            print("🔒 Input blocking enabled - check console for blocking messages")
        } else {
            print("❌ Failed to create run loop source")
            stopBlocking()
        }
    }

    // Stop blocking input events
    func stopBlocking() {
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
            self.runLoopSource = nil
        }

        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            // Note: CFMachPortInvalidate is automatically called when the port is released
            self.eventTap = nil
            print("🔓 Input blocking disabled")
        }
    }

    deinit {
        permissionCheckTimer?.invalidate()
        DistributedNotificationCenter.default().removeObserver(self)
        stopBlocking()
    }
}
