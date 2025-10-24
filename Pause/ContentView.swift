//
//  ContentView.swift
//  Pause
//
//  Created by Harrison Qian on 10/22/25.
//

import SwiftUI
import AppKit
import Carbon.HIToolbox

struct ContentView: View {
    @ObservedObject var appState = AppState.shared
    @ObservedObject var settings = Settings.shared
    @ObservedObject var scheduler = ActivationScheduler.shared

    var body: some View {
        ZStack {
            if appState.isPauseMode {
                // Fullscreen breathing view
                breathingView
            } else {
                // Settings view
                settingsView
            }
        }
    }

    private var settingsView: some View {
        VStack(spacing: 0) {
            // Header - three column layout
            HStack(alignment: .center, spacing: 40) {
                // Left: Session stats
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sessions: \(settings.completedSessions)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Time: \(formatSessionTime(settings.completedSessionTime))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(minWidth: 120)

                // Center: App title
                VStack(spacing: 8) {
                    Text("Pause")
                        .font(.system(size: 32, weight: .light))
                    Text("Press \(settings.getHotkeyString()) to start")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Right: Next activation countdown
                nextActivationView
                    .frame(minWidth: 120)
            }
            .padding(.top, 30)
            .padding(.bottom, 20)

            Divider()

            // Tabbed Settings
            TabView(selection: $settings.selectedTab) {
                sessionSettingsTab
                    .tabItem {
                        Label("General", systemImage: "timer")
                    }
                    .tag(0)

                activationSettingsTab
                    .tabItem {
                        Label("Activation", systemImage: "bell")
                    }
                    .tag(1)

                shortcutsSettingsTab
                    .tabItem {
                        Label("Shortcuts", systemImage: "command")
                    }
                    .tag(2)
            }
            .padding(.top, 10)
        }
        .frame(minWidth: 600, minHeight: 550)
        .textSelection(.enabled)
    }

    private var sessionSettingsTab: some View {
        Form {
                Section {
                    HStack {
                        Text("Pause Duration")
                            .frame(width: 140, alignment: .leading)
                        Slider(value: Binding(
                            get: { Double(settings.pauseDuration) },
                            set: { settings.pauseDuration = Int($0) }
                        ), in: 10...600, step: 10)
                        Text("\(settings.pauseDuration / 60):\(String(format: "%02d", settings.pauseDuration % 60))")
                            .frame(width: 50, alignment: .trailing)
                            .monospacedDigit()
                    }

                    HStack {
                        Text("Time Variance")
                            .frame(width: 140, alignment: .leading)
                        Slider(value: Binding(
                            get: { Double(settings.pauseVariance) },
                            set: { settings.pauseVariance = Int($0) }
                        ), in: 0...120, step: 5)
                        Text("±\(settings.pauseVariance)s")
                            .frame(width: 50, alignment: .trailing)
                            .monospacedDigit()
                    }
                } header: {
                    Text("Timing")
                }

                Section {
                    Toggle("Enable Sound", isOn: $settings.soundEnabled)

                    HStack {
                        Text("Volume")
                            .frame(width: 140, alignment: .leading)
                        Slider(value: $settings.soundVolume, in: 0...1, step: 0.1)
                        Text("\(Int(settings.soundVolume * 100))%")
                            .frame(width: 50, alignment: .trailing)
                            .monospacedDigit()
                    }
                    .disabled(!settings.soundEnabled)

                    HStack {
                        Text("Silence Between")
                            .frame(width: 140, alignment: .leading)
                        Slider(value: Binding(
                            get: { Double(settings.soundRepeatRate) },
                            set: { settings.soundRepeatRate = Int($0) }
                        ), in: 0...30, step: 1)
                        Text("\(settings.soundRepeatRate)s")
                            .frame(width: 50, alignment: .trailing)
                            .monospacedDigit()
                    }
                    .disabled(!settings.soundEnabled)
                } header: {
                    Text("Audio")
                }

                Section {
                    Toggle("Show in Menu Bar", isOn: $settings.showInMenuBar)
                } header: {
                    Text("Appearance")
                }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    private var activationSettingsTab: some View {
        Form {
            // Repeated activation
            Section {
                Toggle("Repeated", isOn: $settings.repeatedEnabled)
                    .toggleStyle(.switch)

                if settings.repeatedEnabled {
                    HStack {
                        Text("Every")
                            .frame(width: 80, alignment: .leading)
                        Slider(value: Binding(
                            get: { Double(settings.repeatedInterval) },
                            set: { settings.repeatedInterval = Int($0) }
                        ), in: 5...240, step: 5)
                        Text("\(settings.repeatedInterval) min")
                            .frame(width: 70, alignment: .trailing)
                            .monospacedDigit()
                    }
                }
            } header: {
                Text("Repeated Activation")
            } footer: {
                if settings.repeatedEnabled {
                    Text("Pause will trigger every \(settings.repeatedInterval) minutes")
                        .font(.caption)
                }
            }

            // Random activation
            Section {
                Toggle("Random", isOn: $settings.randomEnabled)
                    .toggleStyle(.switch)

                if settings.randomEnabled {
                    HStack {
                        Text("Minimum")
                            .frame(width: 80, alignment: .leading)
                        Slider(value: Binding(
                            get: { Double(settings.randomMinInterval) },
                            set: {
                                let newValue = Int($0)
                                settings.randomMinInterval = newValue
                                // Ensure max is always >= min
                                if settings.randomMaxInterval < newValue {
                                    settings.randomMaxInterval = newValue
                                }
                            }
                        ), in: 5...240, step: 5)
                        Text("\(settings.randomMinInterval) min")
                            .frame(width: 70, alignment: .trailing)
                            .monospacedDigit()
                    }

                    HStack {
                        Text("Maximum")
                            .frame(width: 80, alignment: .leading)
                        Slider(value: Binding(
                            get: { Double(settings.randomMaxInterval) },
                            set: {
                                let newValue = Int($0)
                                settings.randomMaxInterval = newValue
                                // Ensure min is always <= max
                                if settings.randomMinInterval > newValue {
                                    settings.randomMinInterval = newValue
                                }
                            }
                        ), in: 5...240, step: 5)
                        Text("\(settings.randomMaxInterval) min")
                            .frame(width: 70, alignment: .trailing)
                            .monospacedDigit()
                    }
                }
            } header: {
                Text("Random Activation")
            } footer: {
                if settings.randomEnabled {
                    Text("Pause will trigger at random intervals between \(settings.randomMinInterval)-\(settings.randomMaxInterval) minutes")
                        .font(.caption)
                }
            }

            // Scheduled activation
            Section {
                Toggle("Scheduled", isOn: $settings.scheduledEnabled)
                    .toggleStyle(.switch)

                if settings.scheduledEnabled {
                    ForEach($settings.scheduledTimes) { $scheduledTime in
                        HStack(alignment: .center, spacing: 8) {
                            TextField("", text: $scheduledTime.name)
                                .textFieldStyle(.roundedBorder)
                                .frame(minWidth: 80, maxWidth: 200)
                                .multilineTextAlignment(.leading)

                            Spacer()

                            DatePicker("", selection: $scheduledTime.date, displayedComponents: .hourAndMinute)
                                .labelsHidden()

                            Button(action: {
                                settings.deleteScheduledTime(id: scheduledTime.id)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onDelete { indices in
                        settings.deleteScheduledTime(at: indices)
                    }

                    HStack {
                        Button("Add Time") {
                            settings.scheduledTimes.append(ScheduledTime(date: Date()))
                        }

                        Spacer()

                        Button("Clear All") {
                            settings.clearAllScheduledTimes()
                        }
                        .disabled(settings.scheduledTimes.isEmpty)

                        Button(action: {
                            settings.undo()
                        }) {
                            Image(systemName: "arrow.uturn.backward")
                        }
                        .disabled(!settings.canUndo)
                        .buttonStyle(.plain)
                        .help("Undo (⌘Z)")
                        .keyboardShortcut("z", modifiers: .command)

                        Button(action: {
                            settings.redo()
                        }) {
                            Image(systemName: "arrow.uturn.forward")
                        }
                        .disabled(!settings.canRedo)
                        .buttonStyle(.plain)
                        .help("Redo (⌘⇧Z)")
                        .keyboardShortcut("z", modifiers: [.command, .shift])
                    }
                }
            } header: {
                Text("Scheduled Activation")
            } footer: {
                if settings.scheduledEnabled {
                    Text("Pause will trigger at the specified times each day")
                        .font(.caption)
                }
            }

            // Recalculation setting
            Section {
                Toggle("Recalculate on Activation", isOn: $settings.recalculateOnActivation)
                    .toggleStyle(.switch)
            } header: {
                Text("Timer Behavior")
            } footer: {
                Text("When enabled, any activation (manual, repeated, random, or scheduled) will reset and recalculate all pending timers. When disabled, timers continue on their original schedules.")
                    .font(.caption)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    private var shortcutsSettingsTab: some View {
        Form {
            Section {
                HotkeyRecorderView()
            } header: {
                Text("Global Hotkey")
            } footer: {
                Text("Press the button below and then press your desired key combination")
                    .font(.caption)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private var nextActivationView: some View {
        NextActivationCountdown()
    }

    private func formatSessionTime(_ seconds: Int) -> String {
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

    private var breathingView: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.4),
                    Color(red: 0.2, green: 0.3, blue: 0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Main message
                Text("Just Breathe")
                    .font(.system(size: 72, weight: .light, design: .rounded))
                    .foregroundColor(.white)

                // Breathing circle animation
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )

                // Timer display
                Text(formatTime(appState.timeRemaining))
                    .font(.system(size: 48, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))

                Spacer()

                // Instructions
                Text("Press SPACE to exit early")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 40)
            }
            .textSelection(.enabled)
        }
    }


    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// Hotkey recorder view
struct HotkeyRecorderView: View {
    @ObservedObject var settings = Settings.shared
    @State private var isRecording = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Current Hotkey:")
                    .frame(width: 140, alignment: .leading)
                Text(settings.getHotkeyString())
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(6)
            }

            Button(action: {
                isRecording = true
            }) {
                HStack {
                    Image(systemName: isRecording ? "record.circle.fill" : "record.circle")
                        .foregroundColor(isRecording ? .red : .primary)
                    Text(isRecording ? "Press your key combination..." : "Record New Hotkey")
                }
            }
            .buttonStyle(.bordered)
        }
        .textSelection(.enabled)
        .background(
            // Invisible overlay to capture key events
            KeyEventHandlingView(isRecording: $isRecording) { keyCode, modifiers in
                if isRecording {
                    // Update settings with new hotkey
                    settings.hotkeyKeyCode = keyCode
                    settings.hotkeyModifiers = modifiers
                    isRecording = false
                }
            }
        )
    }
}

// NSView wrapper to capture key events
struct KeyEventHandlingView: NSViewRepresentable {
    @Binding var isRecording: Bool
    var onKeyPressed: (UInt32, UInt32) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = KeyCaptureView()
        view.onKeyPressed = onKeyPressed
        view.isRecordingBinding = $isRecording
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let keyView = nsView as? KeyCaptureView {
            keyView.isRecordingBinding = $isRecording

            // Auto-focus the view when recording starts
            if isRecording {
                DispatchQueue.main.async {
                    keyView.window?.makeFirstResponder(keyView)
                }
            }
        }
    }
}

class KeyCaptureView: NSView {
    var onKeyPressed: ((UInt32, UInt32) -> Void)?
    var isRecordingBinding: Binding<Bool>?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        guard isRecordingBinding?.wrappedValue == true else {
            super.keyDown(with: event)
            return
        }

        // Convert NSEvent modifiers to Carbon modifiers
        var carbonModifiers: UInt32 = 0
        if event.modifierFlags.contains(.control) {
            carbonModifiers |= UInt32(controlKey)
        }
        if event.modifierFlags.contains(.option) {
            carbonModifiers |= UInt32(optionKey)
        }
        if event.modifierFlags.contains(.shift) {
            carbonModifiers |= UInt32(shiftKey)
        }
        if event.modifierFlags.contains(.command) {
            carbonModifiers |= UInt32(cmdKey)
        }

        // Only accept if at least one modifier is pressed
        if carbonModifiers != 0 {
            onKeyPressed?(UInt32(event.keyCode), carbonModifiers)
        }
    }
}

// Live countdown view for next activation
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

#Preview {
    ContentView()
}
