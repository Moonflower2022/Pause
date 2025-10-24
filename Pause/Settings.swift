//
//  Settings.swift
//  Pause
//
//  Created by Harrison Qian on 10/22/25.
//

import Foundation
import Carbon.HIToolbox

struct ScheduledTime: Codable, Identifiable, Equatable {
    var id: UUID
    var date: Date
    var name: String

    init(id: UUID = UUID(), date: Date, name: String = "") {
        self.id = id
        self.date = date
        self.name = name.isEmpty ? "Time \(DateFormatter.shortTimeFormatter.string(from: date))" : name
    }
}

extension DateFormatter {
    static let shortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

class Settings: ObservableObject {
    static let shared = Settings()

    // Undo/Redo stacks for scheduled times
    private var undoStack: [[ScheduledTime]] = []
    private var redoStack: [[ScheduledTime]] = []
    private let maxUndoStackSize = 50

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

    @Published var startSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(startSoundEnabled, forKey: "startSoundEnabled")
        }
    }

    @Published var startSoundVolume: Double {
        didSet {
            UserDefaults.standard.set(startSoundVolume, forKey: "startSoundVolume")
        }
    }

    @Published var endSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(endSoundEnabled, forKey: "endSoundEnabled")
        }
    }

    @Published var endSoundVolume: Double {
        didSet {
            UserDefaults.standard.set(endSoundVolume, forKey: "endSoundVolume")
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
            ActivationScheduler.shared.updateRepeatedTimer()
        }
    }

    @Published var repeatedInterval: Int {
        didSet {
            UserDefaults.standard.set(repeatedInterval, forKey: "repeatedInterval")
            ActivationScheduler.shared.updateRepeatedTimer()
        }
    }

    @Published var randomEnabled: Bool {
        didSet {
            UserDefaults.standard.set(randomEnabled, forKey: "randomEnabled")
            ActivationScheduler.shared.updateRandomTimer()
        }
    }

    @Published var randomMinInterval: Int {
        didSet {
            UserDefaults.standard.set(randomMinInterval, forKey: "randomMinInterval")
            ActivationScheduler.shared.updateRandomTimer()
        }
    }

    @Published var randomMaxInterval: Int {
        didSet {
            UserDefaults.standard.set(randomMaxInterval, forKey: "randomMaxInterval")
            ActivationScheduler.shared.updateRandomTimer()
        }
    }

    @Published var scheduledEnabled: Bool {
        didSet {
            UserDefaults.standard.set(scheduledEnabled, forKey: "scheduledEnabled")
            ActivationScheduler.shared.updateScheduledTimers()
        }
    }

    @Published var scheduledTimes: [ScheduledTime] {
        didSet {
            if let encoded = try? JSONEncoder().encode(scheduledTimes) {
                UserDefaults.standard.set(encoded, forKey: "scheduledTimes")
            }
            ActivationScheduler.shared.updateScheduledTimers()
        }
    }

    // Methods for undo/redo
    func saveUndoState() {
        undoStack.append(scheduledTimes)
        if undoStack.count > maxUndoStackSize {
            undoStack.removeFirst()
        }
        redoStack.removeAll() // Clear redo stack when new action is performed
    }

    func undo() {
        guard !undoStack.isEmpty else { return }
        redoStack.append(scheduledTimes)
        scheduledTimes = undoStack.removeLast()
    }

    func redo() {
        guard !redoStack.isEmpty else { return }
        undoStack.append(scheduledTimes)
        scheduledTimes = redoStack.removeLast()
    }

    var canUndo: Bool {
        !undoStack.isEmpty
    }

    var canRedo: Bool {
        !redoStack.isEmpty
    }

    func deleteScheduledTime(at offsets: IndexSet) {
        saveUndoState()
        scheduledTimes.remove(atOffsets: offsets)
    }

    func deleteScheduledTime(id: UUID) {
        saveUndoState()
        scheduledTimes.removeAll { $0.id == id }
    }

    func clearAllScheduledTimes() {
        saveUndoState()
        scheduledTimes.removeAll()
    }

    @Published var recalculateOnActivation: Bool {
        didSet {
            UserDefaults.standard.set(recalculateOnActivation, forKey: "recalculateOnActivation")
        }
    }

    // Hotkey settings
    @Published var hotkeyModifiers: UInt32 {
        didSet {
            UserDefaults.standard.set(hotkeyModifiers, forKey: "hotkeyModifiers")
        }
    }

    @Published var hotkeyKeyCode: UInt32 {
        didSet {
            UserDefaults.standard.set(hotkeyKeyCode, forKey: "hotkeyKeyCode")
        }
    }

    // UI State
    @Published var selectedTab: Int {
        didSet {
            UserDefaults.standard.set(selectedTab, forKey: "selectedTab")
        }
    }

    private init() {
        // Load from UserDefaults with default values
        self.pauseDuration = UserDefaults.standard.object(forKey: "pauseDuration") as? Int ?? 60
        self.pauseVariance = UserDefaults.standard.object(forKey: "pauseVariance") as? Int ?? 0
        self.soundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        self.soundVolume = UserDefaults.standard.object(forKey: "soundVolume") as? Double ?? 0.5
        self.soundRepeatRate = UserDefaults.standard.object(forKey: "soundRepeatRate") as? Int ?? 0
        self.startSoundEnabled = UserDefaults.standard.object(forKey: "startSoundEnabled") as? Bool ?? true
        self.startSoundVolume = UserDefaults.standard.object(forKey: "startSoundVolume") as? Double ?? 1.0
        self.endSoundEnabled = UserDefaults.standard.object(forKey: "endSoundEnabled") as? Bool ?? true
        self.endSoundVolume = UserDefaults.standard.object(forKey: "endSoundVolume") as? Double ?? 1.0
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
           let decoded = try? JSONDecoder().decode([ScheduledTime].self, from: data) {
            self.scheduledTimes = decoded
        } else if let data = UserDefaults.standard.data(forKey: "scheduledTimes"),
                  let oldDates = try? JSONDecoder().decode([Date].self, from: data) {
            // Migration from old [Date] format to new [ScheduledTime] format
            self.scheduledTimes = oldDates.map { ScheduledTime(date: $0) }
        } else {
            self.scheduledTimes = []
        }

        self.recalculateOnActivation = UserDefaults.standard.object(forKey: "recalculateOnActivation") as? Bool ?? false

        // Load hotkey settings - default is Control-Command-0
        let defaultModifiers = UInt32(controlKey | cmdKey)
        let defaultKeyCode: UInt32 = 29 // Key code for '0'
        self.hotkeyModifiers = UserDefaults.standard.object(forKey: "hotkeyModifiers") as? UInt32 ?? defaultModifiers
        self.hotkeyKeyCode = UserDefaults.standard.object(forKey: "hotkeyKeyCode") as? UInt32 ?? defaultKeyCode

        // Load UI state
        self.selectedTab = UserDefaults.standard.object(forKey: "selectedTab") as? Int ?? 0
    }

    func getActualPauseDuration() -> Int {
        if pauseVariance == 0 {
            return pauseDuration
        }

        let variance = Int.random(in: -pauseVariance...pauseVariance)
        let duration = pauseDuration + variance
        return max(10, duration) // Minimum 10 seconds
    }

    // Get human-readable hotkey string
    func getHotkeyString() -> String {
        var parts: [String] = []

        // Add modifiers
        if hotkeyModifiers & UInt32(controlKey) != 0 {
            parts.append("⌃")
        }
        if hotkeyModifiers & UInt32(optionKey) != 0 {
            parts.append("⌥")
        }
        if hotkeyModifiers & UInt32(shiftKey) != 0 {
            parts.append("⇧")
        }
        if hotkeyModifiers & UInt32(cmdKey) != 0 {
            parts.append("⌘")
        }

        // Add key name
        parts.append(keyCodeToString(hotkeyKeyCode))

        return parts.joined()
    }

    private func keyCodeToString(_ keyCode: UInt32) -> String {
        // Map common key codes to their string representations
        switch keyCode {
        case 0: return "A"
        case 1: return "S"
        case 2: return "D"
        case 3: return "F"
        case 4: return "H"
        case 5: return "G"
        case 6: return "Z"
        case 7: return "X"
        case 8: return "C"
        case 9: return "V"
        case 11: return "B"
        case 12: return "Q"
        case 13: return "W"
        case 14: return "E"
        case 15: return "R"
        case 16: return "Y"
        case 17: return "T"
        case 18: return "1"
        case 19: return "2"
        case 20: return "3"
        case 21: return "4"
        case 22: return "6"
        case 23: return "5"
        case 24: return "="
        case 25: return "9"
        case 26: return "7"
        case 27: return "-"
        case 28: return "8"
        case 29: return "0"
        case 30: return "]"
        case 31: return "O"
        case 32: return "U"
        case 33: return "["
        case 34: return "I"
        case 35: return "P"
        case 36: return "Return"
        case 37: return "L"
        case 38: return "J"
        case 39: return "'"
        case 40: return "K"
        case 41: return ";"
        case 42: return "\\"
        case 43: return ","
        case 44: return "/"
        case 45: return "N"
        case 46: return "M"
        case 47: return "."
        case 48: return "Tab"
        case 49: return "Space"
        case 50: return "`"
        case 51: return "Delete"
        case 53: return "Escape"
        case 96: return "F5"
        case 97: return "F6"
        case 98: return "F7"
        case 99: return "F3"
        case 100: return "F8"
        case 101: return "F9"
        case 103: return "F11"
        case 105: return "F13"
        case 106: return "F16"
        case 107: return "F14"
        case 109: return "F10"
        case 111: return "F12"
        case 113: return "F15"
        case 115: return "Home"
        case 116: return "Page Up"
        case 117: return "Fwd Delete"
        case 118: return "F4"
        case 119: return "End"
        case 120: return "F2"
        case 121: return "Page Down"
        case 122: return "F1"
        case 123: return "←"
        case 124: return "→"
        case 125: return "↓"
        case 126: return "↑"
        default: return "[\(keyCode)]"
        }
    }
}
