//
//  InputDetectionManager.swift
//  Pause
//
//  Monitors keyboard and mouse input to detect overworking patterns
//

import Cocoa
import Combine
import IOKit.hid

class InputDetectionManager: ObservableObject {
    static let shared = InputDetectionManager()

    @Published var currentCount1: Int = 0
    @Published var currentCount2: Int = 0
    @Published var hasInputMonitoringPermission: Bool = false
    @Published var totalEventsReceived: Int = 0

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var eventTimestamps: [Date] = []
    private let maxTimestampHistory = 300 // Keep last 300 events

    private let settings = Settings.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        print("🔍 InputDetectionManager: Initializing...")
        checkInputMonitoringPermission()
        setupEventTap()

        // Update counts whenever timestamps change
        Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCounts()
            }
            .store(in: &cancellables)

        print("🔍 InputDetectionManager: Initialization complete. Permission: \(hasInputMonitoringPermission)")
    }

    private func checkInputMonitoringPermission() {
        // Check Input Monitoring permission (for listening to events)
        let status = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent)
        hasInputMonitoringPermission = (status == kIOHIDAccessTypeGranted)

        print("🔍 InputDetectionManager: Input Monitoring permission status: \(status.rawValue)")
        print("   kIOHIDAccessTypeGranted = \(kIOHIDAccessTypeGranted.rawValue)")
        print("   kIOHIDAccessTypeDenied = \(kIOHIDAccessTypeDenied.rawValue)")
        print("   kIOHIDAccessTypeUnknown = \(kIOHIDAccessTypeUnknown.rawValue)")

        if !hasInputMonitoringPermission {
            print("⚠️ InputDetectionManager: NO INPUT MONITORING PERMISSION!")
            print("⚠️ Go to: System Settings → Privacy & Security → Input Monitoring")
            print("⚠️ Add Pause to the list and enable it")

            // Request permission - this will prompt the user
            let requestStatus = IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
            print("🔍 InputDetectionManager: Permission request result: \(requestStatus)")

            // Re-check after request
            hasInputMonitoringPermission = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) == kIOHIDAccessTypeGranted
            print("🔍 InputDetectionManager: Permission after request: \(hasInputMonitoringPermission)")
        }
    }

    deinit {
        stop()
    }

    private func setupEventTap() {
        print("🔍 InputDetectionManager: Setting up event tap...")

        // Monitor keyboard and mouse events
        let eventMask = (1 << CGEventType.keyDown.rawValue) |
                       (1 << CGEventType.leftMouseDown.rawValue) |
                       (1 << CGEventType.rightMouseDown.rawValue) |
                       (1 << CGEventType.otherMouseDown.rawValue)

        print("🔍 InputDetectionManager: Event mask: \(eventMask)")

        // Create event tap with listenOnly option (requires Input Monitoring permission)
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,  // Use listenOnly for Input Monitoring (not defaultTap for Accessibility)
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
                let manager = Unmanaged<InputDetectionManager>.fromOpaque(refcon).takeUnretainedValue()
                manager.handleEvent(type: type, event: event)
                return Unmanaged.passUnretained(event)
            },
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        ) else {
            print("❌ InputDetectionManager: FAILED to create event tap!")
            print("❌ This usually means Input Monitoring permissions are not granted.")
            return
        }

        print("✅ InputDetectionManager: Event tap created successfully")

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        print("✅ InputDetectionManager: Event tap enabled and added to run loop")
    }

    private func handleEvent(type: CGEventType, event: CGEvent) {
        totalEventsReceived += 1

        // Log first few events to confirm it's working
        if totalEventsReceived <= 5 {
            print("📥 InputDetectionManager: Event #\(totalEventsReceived) received (type: \(type.rawValue))")
        } else if totalEventsReceived == 6 {
            print("📥 InputDetectionManager: Event tap is working! (suppressing further event logs)")
        }

        guard settings.detectionEnabled else {
            if totalEventsReceived <= 3 {
                print("⚠️ InputDetectionManager: Detection is DISABLED in settings")
            }
            return
        }

        // Record timestamp
        let now = Date()
        eventTimestamps.append(now)

        // Keep only recent timestamps
        if eventTimestamps.count > maxTimestampHistory {
            eventTimestamps.removeFirst()
        }

        // Update counts and check thresholds
        updateCounts()
        checkThresholds()
    }

    private func updateCounts() {
        guard settings.detectionEnabled else {
            currentCount1 = 0
            currentCount2 = 0
            return
        }

        let now = Date()
        let latency1 = settings.detectionLatency1
        let latency2 = settings.detectionLatency2

        // Count events within each latency window
        var count1 = 0
        var count2 = 0

        for i in 0..<eventTimestamps.count {
            let timestamp = eventTimestamps[i]
            let age = now.timeIntervalSince(timestamp)

            // Count consecutive events within latency threshold
            if i > 0 {
                let timeSincePrevious = timestamp.timeIntervalSince(eventTimestamps[i-1])

                if timeSincePrevious < latency1 {
                    count1 += 1
                }

                if timeSincePrevious < latency2 {
                    count2 += 1
                }
            }

            // Don't count events that are too old
            if age > max(latency1, latency2) * 2 {
                continue
            }
        }

        currentCount1 = count1
        currentCount2 = count2
    }

    private func checkThresholds() {
        guard settings.detectionEnabled else { return }

        let threshold1Met = currentCount1 >= settings.detectionCountThreshold1
        let threshold2Met = currentCount2 >= settings.detectionCountThreshold2

        var shouldActivate = false

        if settings.andEnabled {
            // Both thresholds must be met
            shouldActivate = threshold1Met && threshold2Met
        } else {
            // Either threshold can trigger
            shouldActivate = threshold1Met || threshold2Met
        }

        if shouldActivate {
            print("🚨 InputDetectionManager: THRESHOLD MET!")
            print("   Count1: \(currentCount1)/\(settings.detectionCountThreshold1) (met: \(threshold1Met))")
            print("   Count2: \(currentCount2)/\(settings.detectionCountThreshold2) (met: \(threshold2Met))")
            print("   Mode: \(settings.andEnabled ? "AND" : "OR")")
            triggerActivation()
        }
    }

    private func triggerActivation() {
        print("🎯 InputDetectionManager: TRIGGERING PAUSE MODE!")

        // Clear timestamps to prevent immediate re-trigger
        eventTimestamps.removeAll()
        currentCount1 = 0
        currentCount2 = 0

        print("🎯 InputDetectionManager: Counts reset. Calling AppState.triggerPauseMode()...")

        // Trigger pause session via AppState
        DispatchQueue.main.async {
            print("🎯 InputDetectionManager: Executing AppState.triggerPauseMode() on main thread")
            AppState.shared.triggerPauseMode()
            print("🎯 InputDetectionManager: AppState.triggerPauseMode() called")
        }
    }

    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
    }
}
