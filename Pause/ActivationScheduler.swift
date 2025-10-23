//
//  ActivationScheduler.swift
//  Pause
//
//  Created by Harrison Qian on 10/22/25.
//

import Foundation

class ActivationScheduler: ObservableObject {
    static let shared = ActivationScheduler()

    @Published var nextRandomActivation: Date?
    @Published var randomActivationRange: String = ""

    private var repeatedTimer: Timer?
    private var randomTimer: Timer?
    private var scheduledTimers: [Timer] = []

    private init() {
        // Start monitoring settings changes
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateSchedule()
        }

        // Initial setup
        updateSchedule()
    }

    func updateSchedule() {
        // Clear existing timers
        clearAllTimers()

        let settings = Settings.shared

        // Each mode can be enabled independently
        if settings.repeatedEnabled {
            setupRepeatedTimer()
        }

        if settings.randomEnabled {
            setupRandomTimer()
        }

        if settings.scheduledEnabled {
            setupScheduledTimers()
        }
    }

    // Public method to recalculate timers when an activation occurs
    func recalculateTimers() {
        print("Recalculating all timers due to activation")
        updateSchedule()
    }

    private func setupRepeatedTimer() {
        let intervalMinutes = Settings.shared.repeatedInterval
        let intervalSeconds = TimeInterval(intervalMinutes * 60)

        print("Setting up repeated timer: every \(intervalMinutes) minutes")

        repeatedTimer = Timer.scheduledTimer(withTimeInterval: intervalSeconds, repeats: true) { _ in
            print("Repeated timer fired - triggering pause mode")
            AppState.shared.triggerPauseMode()
        }
    }

    private func setupRandomTimer() {
        let minMinutes = Settings.shared.randomMinInterval
        let maxMinutes = Settings.shared.randomMaxInterval

        // Ensure min <= max to avoid crash
        guard minMinutes <= maxMinutes else {
            print("Error: Random min (\(minMinutes)) is greater than max (\(maxMinutes)). Skipping random timer setup.")
            return
        }

        let randomMinutes = Int.random(in: minMinutes...maxMinutes)
        let intervalSeconds = TimeInterval(randomMinutes * 60)

        // Calculate when it will fire
        let fireDate = Date().addingTimeInterval(intervalSeconds)

        // Update published properties
        DispatchQueue.main.async {
            self.nextRandomActivation = fireDate
            self.randomActivationRange = "\(minMinutes)-\(maxMinutes) min"
        }

        print("Setting up random timer: will fire in \(randomMinutes) minutes (range: \(minMinutes)-\(maxMinutes) min)")
        print("Next random activation at: \(fireDate.formatted(date: .omitted, time: .shortened))")

        randomTimer = Timer.scheduledTimer(withTimeInterval: intervalSeconds, repeats: false) { [weak self] _ in
            print("Random timer fired - triggering pause mode")
            AppState.shared.triggerPauseMode()

            // Schedule the next random timer
            self?.setupRandomTimer()
        }
    }

    private func setupScheduledTimers() {
        let scheduledTimes = Settings.shared.scheduledTimes

        print("Setting up scheduled timers for \(scheduledTimes.count) times")

        for scheduledTime in scheduledTimes {
            if let timer = createDailyTimer(for: scheduledTime) {
                scheduledTimers.append(timer)
            }
        }
    }

    private func createDailyTimer(for time: Date) -> Timer? {
        let calendar = Calendar.current
        let now = Date()

        // Extract hour and minute from the scheduled time
        let components = calendar.dateComponents([.hour, .minute], from: time)

        guard let hour = components.hour, let minute = components.minute else {
            return nil
        }

        // Create a date for today at the scheduled time
        var todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        todayComponents.hour = hour
        todayComponents.minute = minute
        todayComponents.second = 0

        guard var scheduledDate = calendar.date(from: todayComponents) else {
            return nil
        }

        // If the time has already passed today, schedule for tomorrow
        if scheduledDate < now {
            scheduledDate = calendar.date(byAdding: .day, value: 1, to: scheduledDate) ?? scheduledDate
        }

        let timeInterval = scheduledDate.timeIntervalSinceNow

        print("Scheduling timer for \(hour):\(String(format: "%02d", minute)) - fires in \(Int(timeInterval/60)) minutes")

        return Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            print("Scheduled timer fired - triggering pause mode")
            AppState.shared.triggerPauseMode()

            // Reschedule for tomorrow
            if let newTimer = self?.createDailyTimer(for: time) {
                self?.scheduledTimers.append(newTimer)
            }
        }
    }

    private func clearAllTimers() {
        repeatedTimer?.invalidate()
        repeatedTimer = nil

        randomTimer?.invalidate()
        randomTimer = nil
        nextRandomActivation = nil
        randomActivationRange = ""

        scheduledTimers.forEach { $0.invalidate() }
        scheduledTimers.removeAll()
    }

    deinit {
        clearAllTimers()
    }
}
