//
//  NextActivationCountdown.swift
//  Pause
//
//  Live countdown view for next activation
//

import SwiftUI

struct NextActivationCountdown: View {
    @ObservedObject var scheduler = ActivationScheduler.shared
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?

    var body: some View {
        if let nextActivation = getNextActivation() {
            VStack(alignment: .trailing, spacing: 4) {
                Text("Next: \(nextActivation.type)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatCountdown(timeRemaining))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .textSelection(.enabled)
            .onAppear {
                updateTimeRemaining()
                // Update every second - add to common modes so it runs during UI tracking (slider dragging, etc)
                let newTimer = Timer(timeInterval: 1.0, repeats: true) { _ in
                    updateTimeRemaining()
                }
                RunLoop.current.add(newTimer, forMode: .common)
                timer = newTimer
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
        } else {
            VStack(alignment: .trailing, spacing: 4) {
                Text("No automatic")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("pauses scheduled")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .textSelection(.enabled)
        }
    }

    private func getNextActivation() -> (date: Date, type: String)? {
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

    private func updateTimeRemaining() {
        if let nextActivation = getNextActivation() {
            timeRemaining = max(0, nextActivation.date.timeIntervalSinceNow)
        } else {
            timeRemaining = 0
        }
    }

    private func formatCountdown(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60

        if hours > 0 {
            return String(format: "in %dh %dm %ds", hours, minutes, secs)
        } else if minutes > 0 {
            return String(format: "in %dm %ds", minutes, secs)
        } else {
            return String(format: "in %ds", secs)
        }
    }
}
