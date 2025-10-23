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
