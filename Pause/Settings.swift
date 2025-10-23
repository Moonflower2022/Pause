//
//  Settings.swift
//  Pause
//
//  Created by Harrison Qian on 10/22/25.
//

import Foundation

class Settings: ObservableObject {
    static let shared = Settings()

    @Published var pauseDuration: Int {
        didSet {
            UserDefaults.standard.set(pauseDuration, forKey: "pauseDuration")
        }
    }

    @Published var pauseVariance: Int {
        didSet {
            UserDefaults.standard.set(pauseVariance, forKey: "pauseVariance")
        }
    }

    @Published var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        }
    }

    @Published var soundVolume: Double {
        didSet {
            UserDefaults.standard.set(soundVolume, forKey: "soundVolume")
        }
    }

    @Published var soundRepeatRate: Int {
        didSet {
            UserDefaults.standard.set(soundRepeatRate, forKey: "soundRepeatRate")
        }
    }

    @Published var showInMenuBar: Bool {
        didSet {
            UserDefaults.standard.set(showInMenuBar, forKey: "showInMenuBar")
        }
    }

    @Published var completedSessions: Int {
        didSet {
            UserDefaults.standard.set(completedSessions, forKey: "completedSessions")
        }
    }

    @Published var completedSessionTime: Int {
        didSet {
            UserDefaults.standard.set(completedSessionTime, forKey: "completedSessionTime")
        }
    }

    // Activation settings - each mode can be toggled independently
    @Published var repeatedEnabled: Bool {
        didSet {
            UserDefaults.standard.set(repeatedEnabled, forKey: "repeatedEnabled")
        }
    }

    @Published var repeatedInterval: Int {
        didSet {
            UserDefaults.standard.set(repeatedInterval, forKey: "repeatedInterval")
        }
    }

    @Published var randomEnabled: Bool {
        didSet {
            UserDefaults.standard.set(randomEnabled, forKey: "randomEnabled")
        }
    }

    @Published var randomMinInterval: Int {
        didSet {
            UserDefaults.standard.set(randomMinInterval, forKey: "randomMinInterval")
        }
    }

    @Published var randomMaxInterval: Int {
        didSet {
            UserDefaults.standard.set(randomMaxInterval, forKey: "randomMaxInterval")
        }
    }

    @Published var scheduledEnabled: Bool {
        didSet {
            UserDefaults.standard.set(scheduledEnabled, forKey: "scheduledEnabled")
        }
    }

    @Published var scheduledTimes: [Date] {
        didSet {
            if let encoded = try? JSONEncoder().encode(scheduledTimes) {
                UserDefaults.standard.set(encoded, forKey: "scheduledTimes")
            }
        }
    }

    @Published var recalculateOnActivation: Bool {
        didSet {
            UserDefaults.standard.set(recalculateOnActivation, forKey: "recalculateOnActivation")
        }
    }

    private init() {
        // Load from UserDefaults with default values
        self.pauseDuration = UserDefaults.standard.object(forKey: "pauseDuration") as? Int ?? 60
        self.pauseVariance = UserDefaults.standard.object(forKey: "pauseVariance") as? Int ?? 0
        self.soundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        self.soundVolume = UserDefaults.standard.object(forKey: "soundVolume") as? Double ?? 0.5
        self.soundRepeatRate = UserDefaults.standard.object(forKey: "soundRepeatRate") as? Int ?? 0
        self.showInMenuBar = UserDefaults.standard.object(forKey: "showInMenuBar") as? Bool ?? false
        self.completedSessions = UserDefaults.standard.object(forKey: "completedSessions") as? Int ?? 0
        self.completedSessionTime = UserDefaults.standard.object(forKey: "completedSessionTime") as? Int ?? 0

        // Load activation settings
        self.repeatedEnabled = UserDefaults.standard.object(forKey: "repeatedEnabled") as? Bool ?? false
        self.repeatedInterval = UserDefaults.standard.object(forKey: "repeatedInterval") as? Int ?? 60 // Default 60 minutes

        self.randomEnabled = UserDefaults.standard.object(forKey: "randomEnabled") as? Bool ?? false
        self.randomMinInterval = UserDefaults.standard.object(forKey: "randomMinInterval") as? Int ?? 30 // Default 30 minutes
        self.randomMaxInterval = UserDefaults.standard.object(forKey: "randomMaxInterval") as? Int ?? 120 // Default 120 minutes

        self.scheduledEnabled = UserDefaults.standard.object(forKey: "scheduledEnabled") as? Bool ?? false
        if let data = UserDefaults.standard.data(forKey: "scheduledTimes"),
           let decoded = try? JSONDecoder().decode([Date].self, from: data) {
            self.scheduledTimes = decoded
        } else {
            self.scheduledTimes = []
        }

        self.recalculateOnActivation = UserDefaults.standard.object(forKey: "recalculateOnActivation") as? Bool ?? false
    }

    func getActualPauseDuration() -> Int {
        if pauseVariance == 0 {
            return pauseDuration
        }

        let variance = Int.random(in: -pauseVariance...pauseVariance)
        let duration = pauseDuration + variance
        return max(10, duration) // Minimum 10 seconds
    }
}
