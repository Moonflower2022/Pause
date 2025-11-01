//
//  DoomScrollDetector.swift
//  Pause
//
//  Detects doom scrolling patterns based on velocity, directionality, and minimal pauses
//

import Foundation
import AppKit

enum ScrollEventType {
    case scrollDown
    case scrollUp
    case keyDown
    case keyRight
    case keyUp
    case keyLeft
}

struct ScrollEvent {
    let timestamp: Date
    let type: ScrollEventType
    let delta: Double // For scroll wheel - magnitude of scroll
}

class DoomScrollDetector: ObservableObject {
    static let shared = DoomScrollDetector()

    private var eventQueue: [ScrollEvent] = []
    private let queueLock = NSLock()
    private var lastCheckTime: Date = Date()

    private let settings = Settings.shared

    private init() {
        // Start periodic check timer (every 5 seconds)
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkForDoomScrolling()
        }
    }

    // MARK: - Event Recording

    func recordScrollEvent(deltaY: Double) {
        guard settings.doomScrollEnabled else { return }

        let type: ScrollEventType = deltaY > 0 ? .scrollDown : .scrollUp
        let event = ScrollEvent(timestamp: Date(), type: type, delta: abs(deltaY))

        queueLock.lock()
        eventQueue.append(event)
        queueLock.unlock()

        pruneOldEvents()
    }

    func recordKeyEvent(keyCode: UInt16) {
        guard settings.doomScrollEnabled else { return }

        let type: ScrollEventType?

        switch keyCode {
        case 125: // Down arrow
            type = .keyDown
        case 126: // Up arrow
            type = .keyUp
        case 124: // Right arrow
            type = .keyRight
        case 123: // Left arrow
            type = .keyLeft
        default:
            type = nil
        }

        guard let eventType = type else { return }

        let event = ScrollEvent(timestamp: Date(), type: eventType, delta: 1.0)

        queueLock.lock()
        eventQueue.append(event)
        queueLock.unlock()

        pruneOldEvents()
    }

    // MARK: - Event Management

    private func pruneOldEvents() {
        let windowDuration = TimeInterval(settings.doomScrollWindowDuration * 60) // Convert minutes to seconds
        let cutoffTime = Date().addingTimeInterval(-windowDuration)

        queueLock.lock()
        eventQueue.removeAll { $0.timestamp < cutoffTime }
        queueLock.unlock()
    }

    // MARK: - Detection Logic

    private func checkForDoomScrolling() {
        guard settings.doomScrollEnabled else { return }

        queueLock.lock()
        let events = eventQueue
        queueLock.unlock()

        guard !events.isEmpty else { return }

        // Calculate metrics
        let velocity = calculateVelocity(events: events)
        let directionality = calculateDirectionality(events: events)
        let medianPause = calculateMedianPause(events: events)

        // Check if all conditions are met
        let velocityMet = velocity >= Double(settings.doomScrollVelocityThreshold)
        let directionalityMet = directionality >= settings.doomScrollDirectionalityThreshold
        let pauseMet = medianPause <= settings.doomScrollPauseThreshold

        if velocityMet && directionalityMet && pauseMet {
            // Doom scrolling detected! Trigger pause session
            DispatchQueue.main.async {
                AppState.shared.startPauseMode()
            }

            // Clear the queue to avoid immediate re-triggering
            queueLock.lock()
            eventQueue.removeAll()
            queueLock.unlock()

            print("🚨 Doom scrolling detected! Velocity: \(String(format: "%.1f", velocity))/min, Directionality: \(String(format: "%.2f", directionality)), Median pause: \(String(format: "%.2f", medianPause))s")
        }
    }

    // MARK: - Metric Calculations

    /// Calculate velocity: forward actions per minute
    private func calculateVelocity(events: [ScrollEvent]) -> Double {
        guard !events.isEmpty else { return 0 }

        let forwardEvents = events.filter { isForwardEvent($0.type) }

        // Calculate duration of the window
        guard let firstTime = events.first?.timestamp,
              let lastTime = events.last?.timestamp else { return 0 }

        let duration = lastTime.timeIntervalSince(firstTime)
        guard duration > 0 else { return 0 }

        let durationInMinutes = duration / 60.0
        return Double(forwardEvents.count) / durationInMinutes
    }

    /// Calculate directionality: ratio of forward to total actions
    private func calculateDirectionality(events: [ScrollEvent]) -> Double {
        guard !events.isEmpty else { return 0 }

        let forwardCount = events.filter { isForwardEvent($0.type) }.count
        let backwardCount = events.filter { isBackwardEvent($0.type) }.count
        let total = forwardCount + backwardCount

        guard total > 0 else { return 0 }

        return Double(forwardCount) / Double(total)
    }

    /// Calculate median pause duration between events
    private func calculateMedianPause(events: [ScrollEvent]) -> Double {
        guard events.count > 1 else { return Double.infinity }

        var gaps: [TimeInterval] = []

        for i in 0..<(events.count - 1) {
            let gap = events[i + 1].timestamp.timeIntervalSince(events[i].timestamp)
            gaps.append(gap)
        }

        guard !gaps.isEmpty else { return Double.infinity }

        // Calculate median
        let sorted = gaps.sorted()
        let count = sorted.count

        if count % 2 == 0 {
            return (sorted[count / 2 - 1] + sorted[count / 2]) / 2.0
        } else {
            return sorted[count / 2]
        }
    }

    // MARK: - Helper Functions

    private func isForwardEvent(_ type: ScrollEventType) -> Bool {
        return type == .scrollDown || type == .keyDown || type == .keyRight
    }

    private func isBackwardEvent(_ type: ScrollEventType) -> Bool {
        return type == .scrollUp || type == .keyUp || type == .keyLeft
    }
}
