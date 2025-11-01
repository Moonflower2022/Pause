//
//  NoGoSettingsTab.swift
//  Pause
//
//  Settings for preventing interruptions
//

import SwiftUI

struct NoGoSettingsTab: View {
    @ObservedObject var settings = Settings.shared
    @ObservedObject var detector = InputDetectionManager.shared

    var body: some View {
        Form {
            // SECTION 1: Don't Interrupt (Input Detection)
            Section {
                Toggle("Don't Interrupt While Working", isOn: $settings.detectionEnabled)
                    .toggleStyle(.switch)

                if settings.detectionEnabled {
                    HStack {
                        Text("Minimum Buffer")
                            .frame(width: 140, alignment: .leading)
                        Slider(value: Binding(
                            get: { Double(settings.inputDelayBuffer) },
                            set: { settings.inputDelayBuffer = Int($0) }
                        ), in: 10...300, step: 5)
                        Text("\(settings.inputDelayBuffer)s")
                            .frame(width: 60, alignment: .trailing)
                            .monospacedDigit()
                    }
                }

                // System status
                if settings.detectionEnabled {
                    HStack {
                        Text("Input Monitoring Permission")
                            .frame(width: 180, alignment: .leading)
                        if detector.hasInputMonitoringPermission {
                            Text("✅ Granted")
                                .foregroundColor(.green)
                        } else {
                            Text("❌ Not Granted")
                                .foregroundColor(.red)
                        }

                        Spacer()

                        if !detector.hasInputMonitoringPermission {
                            Button("Open System Settings") {
                                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") {
                                    NSWorkspace.shared.open(url)
                                }
                            }
                        }
                    }

                }
            } header: {
                Text("Don't Interrupt")
            } footer: {
                if settings.detectionEnabled {
                    Text("When you type or click, scheduled activations closer than \(settings.inputDelayBuffer) seconds will be delayed. This prevents interruptions while actively working.")
                        .font(.caption)
                } else {
                    Text("When enabled, keyboard or mouse input will delay upcoming activations to prevent interruptions while you're working.")
                        .font(.caption)
                }
            }

            // SECTION 2: No-Go Times
            Section {
                Toggle("No-Go Times", isOn: Binding(
                    get: { settings.noGoEnabled },
                    set: { newValue in
                        if !newValue {
                            // Clear all no-go times when disabling
                            settings.noGoTimes.removeAll()
                        }
                        settings.noGoEnabled = newValue
                    }
                ))
                .toggleStyle(.switch)
            } header: {
                Text("No-Go Times")
            } footer: {
                Text("Prevent activations during specified time periods. Turning this off will remove all configured times.")
                    .font(.caption)
            }

            // Recurring no-go times (daily)
            Section {
                ForEach($settings.noGoTimes.filter { $0.wrappedValue.isRecurring }) { $noGoTime in
                    NoGoTimeRow(noGoTime: $noGoTime, onDelete: {
                        settings.deleteNoGoTime(id: noGoTime.id)
                    })
                }

                HStack {
                    Button("Add No-Go Time") {
                        let now = Date()
                        let calendar = Calendar.current

                        // Create default start time (e.g., 9 AM)
                        var startComponents = calendar.dateComponents([.year, .month, .day], from: now)
                        startComponents.hour = 9
                        startComponents.minute = 0

                        // Create default end time (e.g., 5 PM)
                        var endComponents = calendar.dateComponents([.year, .month, .day], from: now)
                        endComponents.hour = 17
                        endComponents.minute = 0

                        if let startTime = calendar.date(from: startComponents),
                           let endTime = calendar.date(from: endComponents) {
                            settings.noGoTimes.append(NoGoTime(
                                startTime: startTime,
                                endTime: endTime,
                                name: "Work Hours",
                                isRecurring: true
                            ))
                        }
                    }
                    .disabled(!settings.noGoEnabled)

                    Spacer()

                    Button("Clear All") {
                        settings.noGoTimes.removeAll { $0.isRecurring }
                    }
                    .disabled(!settings.noGoEnabled || settings.noGoTimes.filter({ $0.isRecurring }).isEmpty)
                }
            } header: {
                Text("Daily No-Go Times")
            } footer: {
                Text("Automatic activations will not trigger during these periods every day.")
                    .font(.caption)
            }

            // Day-specific no-go times (specific day of week)
            Section {
                ForEach($settings.noGoTimes.filter { !$0.wrappedValue.isRecurring && $0.wrappedValue.dayOfWeek != nil }) { $noGoTime in
                    NoGoTimeRow(noGoTime: $noGoTime, onDelete: {
                        settings.deleteNoGoTime(id: noGoTime.id)
                    })
                }

                HStack {
                    Button("Add Day-Specific No-Go Time") {
                        let now = Date()
                        let calendar = Calendar.current
                        let currentWeekday = calendar.component(.weekday, from: now)

                        // Create default start time (9 AM)
                        var startComponents = calendar.dateComponents([.year, .month, .day], from: now)
                        startComponents.hour = 9
                        startComponents.minute = 0

                        // Create default end time (5 PM)
                        var endComponents = calendar.dateComponents([.year, .month, .day], from: now)
                        endComponents.hour = 17
                        endComponents.minute = 0

                        if let startTime = calendar.date(from: startComponents),
                           let endTime = calendar.date(from: endComponents) {
                            settings.noGoTimes.append(NoGoTime(
                                startTime: startTime,
                                endTime: endTime,
                                name: "Work Hours",
                                isRecurring: false,
                                dayOfWeek: currentWeekday
                            ))
                        }
                    }
                    .disabled(!settings.noGoEnabled)

                    Spacer()

                    Button("Clear All Day-Specific") {
                        settings.noGoTimes.removeAll { !$0.isRecurring && $0.dayOfWeek != nil }
                    }
                    .disabled(!settings.noGoEnabled || settings.noGoTimes.filter({ !$0.isRecurring && $0.dayOfWeek != nil }).isEmpty)
                }
            } header: {
                Text("Day-Specific No-Go Times")
            } footer: {
                Text("These times only apply on the selected day of the week.")
                    .font(.caption)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

struct NoGoTimeRow: View {
    @Binding var noGoTime: NoGoTime
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            TextField("Label:", text: $noGoTime.name)
                .textFieldStyle(.roundedBorder)
                .frame(minWidth: 80, maxWidth: 200)
                .multilineTextAlignment(.leading)

            Spacer()

            // Show day picker only for day-specific times (not today-only)
            if !noGoTime.isRecurring && noGoTime.dayOfWeek != nil {
                let dayOfWeek = Binding(
                    get: { noGoTime.dayOfWeek ?? 1 },
                    set: { noGoTime.dayOfWeek = $0 }
                )
                Picker("Day", selection: dayOfWeek) {
                    Text("Sun").tag(1)
                    Text("Mon").tag(2)
                    Text("Tue").tag(3)
                    Text("Wed").tag(4)
                    Text("Thu").tag(5)
                    Text("Fri").tag(6)
                    Text("Sat").tag(7)
                }
                .pickerStyle(.segmented)
                .frame(width: 280)
            }

            Text("From")
                .foregroundStyle(.secondary)
                .font(.caption)

            DatePicker("", selection: $noGoTime.startTime, displayedComponents: .hourAndMinute)
                .labelsHidden()

            Text("to")
                .foregroundStyle(.secondary)
                .font(.caption)

            DatePicker("", selection: $noGoTime.endTime, displayedComponents: .hourAndMinute)
                .labelsHidden()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
    }
}
