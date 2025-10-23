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

    @Published var musicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(musicEnabled, forKey: "musicEnabled")
        }
    }

    @Published var musicVolume: Double {
        didSet {
            UserDefaults.standard.set(musicVolume, forKey: "musicVolume")
        }
    }

    @Published var musicRepeatRate: Int {
        didSet {
            UserDefaults.standard.set(musicRepeatRate, forKey: "musicRepeatRate")
        }
    }

    @Published var showInMenuBar: Bool {
        didSet {
            UserDefaults.standard.set(showInMenuBar, forKey: "showInMenuBar")
        }
    }

    private init() {
        // Load from UserDefaults with default values
        self.pauseDuration = UserDefaults.standard.object(forKey: "pauseDuration") as? Int ?? 60
        self.pauseVariance = UserDefaults.standard.object(forKey: "pauseVariance") as? Int ?? 0
        self.musicEnabled = UserDefaults.standard.object(forKey: "musicEnabled") as? Bool ?? true
        self.musicVolume = UserDefaults.standard.object(forKey: "musicVolume") as? Double ?? 0.5
        self.musicRepeatRate = UserDefaults.standard.object(forKey: "musicRepeatRate") as? Int ?? 0
        self.showInMenuBar = UserDefaults.standard.object(forKey: "showInMenuBar") as? Bool ?? false
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
