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

    @Published var hasInputMonitoringPermission: Bool = false
    @Published var totalEventsReceived: Int = 0
    @Published var lastInputTime: Date?

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let eventQueue = DispatchQueue(label: "com.pause.inputdetection", qos: .userInteractive)

    private let settings = Settings.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        print("🔍 InputDetectionManager: Initializing...")
        checkInputMonitoringPermission()
        setupEventTap()

        // Monitor permission changes
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkPermissionStatus()
            }
            .store(in: &cancellables)

        print("🔍 InputDetectionManager: Initialization complete. Permission: \(hasInputMonitoringPermission)")
    }

    private func checkPermissionStatus() {
        let status = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent)
        let newPermissionStatus = (status == kIOHIDAccessTypeGranted)

        if newPermissionStatus != hasInputMonitoringPermission {
            hasInputMonitoringPermission = newPermissionStatus
            print("🔍 InputDetectionManager: Permission status changed to: \(hasInputMonitoringPermission)")

            // If permission was just granted, set up event tap
            if hasInputMonitoringPermission && eventTap == nil {
                print("🔍 InputDetectionManager: Permission granted, setting up event tap...")
                setupEventTap()
            }
        }
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
        eventQueue.async { [weak self] in
            guard let self = self else { return }

            let eventCount = self.totalEventsReceived + 1

            // Update @Published properties on main thread
            DispatchQueue.main.async {
                self.totalEventsReceived = eventCount
                self.lastInputTime = Date()
            }

            // Log first few events to confirm it's working
            if eventCount <= 5 {
                print("📥 InputDetectionManager: Event #\(eventCount) received (type: \(type.rawValue))")
            } else if eventCount == 6 {
                print("📥 InputDetectionManager: Event tap is working! (suppressing further event logs)")
            }

            guard self.settings.detectionEnabled else {
                if eventCount <= 3 {
                    print("⚠️ InputDetectionManager: Detection is DISABLED in settings")
                }
                return
            }

            // Enforce minimum buffer on scheduled activations
            DispatchQueue.main.async {
                ActivationScheduler.shared.enforceMinimumBuffer()
            }
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
