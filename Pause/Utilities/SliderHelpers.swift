//
//  SliderHelpers.swift
//  Pause
//
//  Helper functions for non-linear sliders and time formatting
//

import Foundation

struct SliderHelpers {
    // Duration steps for session length (in seconds)
    // 30s, 1m, 2m, 3m, 4m, 5m, 10m, 15m, 20m, 30m, 45m, 1h, 1.5h, 2h, 3h, 5h, 10h
    static func durationSteps() -> [Int] {
        return [30, 60, 120, 180, 240, 300, 600, 900, 1200, 1800, 2700, 3600, 5400, 7200, 10800, 18000, 36000]
    }

    // Activation interval steps (in minutes)
    // 30s, 1m, 5m, 10m, 15m, 20m, 25m, 30m, 45m, 1h, 1h30m, 2h, 3h, 5h, 10h
    static func activationSteps() -> [Int] {
        return [0, 1, 5, 10, 15, 20, 25, 30, 45, 60, 90, 120, 180, 300, 600]
    }

    // Variance steps for time randomization (in seconds)
    // 0s, 5s, 10s, 15s, 30s, 1m, 2m, 5m, 10m
    static func varianceSteps() -> [Int] {
        return [0, 5, 10, 15, 30, 60, 120, 300, 600]
    }

    // Buffer steps for input delay (in seconds)
    // 1s, 2s, 5s, 10s, 15s, 30s, 1m, 1.5m, 2m, 3m, 5m
    static func bufferSteps() -> [Int] {
        return [1, 2, 5, 10, 15, 30, 60, 90, 120, 180, 300]
    }

    // Find slider index for a given duration value
    static func indexForDuration(_ duration: Int) -> Double {
        let steps = durationSteps()
        if let index = steps.firstIndex(of: duration) {
            return Double(index)
        }
        // Find closest
        for (index, step) in steps.enumerated() {
            if duration <= step {
                return Double(index)
            }
        }
        return Double(steps.count - 1)
    }

    // Find slider index for a given activation interval
    static func indexForActivation(_ minutes: Int) -> Double {
        let steps = activationSteps()
        if let index = steps.firstIndex(of: minutes) {
            return Double(index)
        }
        // Find closest
        for (index, step) in steps.enumerated() {
            if minutes <= step {
                return Double(index)
            }
        }
        return Double(steps.count - 1)
    }

    // Find slider index for a given variance value
    static func indexForVariance(_ variance: Int) -> Double {
        let steps = varianceSteps()
        if let index = steps.firstIndex(of: variance) {
            return Double(index)
        }
        // Find closest
        for (index, step) in steps.enumerated() {
            if variance <= step {
                return Double(index)
            }
        }
        return Double(steps.count - 1)
    }

    // Find slider index for a given buffer value
    static func indexForBuffer(_ buffer: Int) -> Double {
        let steps = bufferSteps()
        if let index = steps.firstIndex(of: buffer) {
            return Double(index)
        }
        // Find closest
        for (index, step) in steps.enumerated() {
            if buffer <= step {
                return Double(index)
            }
        }
        return Double(steps.count - 1)
    }

    // Format duration in seconds to human-readable string
    static func formatDuration(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)s"
        } else if seconds < 3600 {
            let mins = seconds / 60
            return "\(mins)m"
        } else {
            let hours = seconds / 3600
            let mins = (seconds % 3600) / 60
            if mins == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(mins)m"
            }
        }
    }

    // Format activation interval in minutes to human-readable string
    static func formatActivation(_ minutes: Int) -> String {
        if minutes == 0 {
            return "30s"
        } else if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(mins)m"
            }
        }
    }

    // Format buffer time in seconds to human-readable string
    static func formatBuffer(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)s"
        } else {
            let mins = seconds / 60
            let secs = seconds % 60
            if secs == 0 {
                return "\(mins)m"
            } else {
                return "\(mins)m \(secs)s"
            }
        }
    }

    // Format session time in seconds to h/m/s format
    static func formatSessionTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, secs)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, secs)
        } else {
            return String(format: "%ds", secs)
        }
    }
}
