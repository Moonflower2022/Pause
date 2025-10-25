//
//  ActivationSettingsTab.swift
//  Pause
//
//  Activation settings for repeated, random, and scheduled timers
//

import SwiftUI

struct ActivationSettingsTab: View {
    @ObservedObject var settings = Settings.shared

    var body: some View {
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
                            get: { SliderHelpers.indexForActivation(settings.repeatedInterval) },
                            set: { settings.repeatedInterval = SliderHelpers.activationSteps()[Int($0)] }
                        ), in: 0...Double(SliderHelpers.activationSteps().count - 1), step: 1)
                        Text(SliderHelpers.formatActivation(settings.repeatedInterval))
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
                            get: { SliderHelpers.indexForActivation(settings.randomMinInterval) },
                            set: {
                                let newValue = SliderHelpers.activationSteps()[Int($0)]
                                settings.randomMinInterval = newValue
                                // Ensure max is always >= min
                                if settings.randomMaxInterval < newValue {
                                    settings.randomMaxInterval = newValue
                                }
                            }
                        ), in: 0...Double(SliderHelpers.activationSteps().count - 1), step: 1)
                        Text(SliderHelpers.formatActivation(settings.randomMinInterval))
                            .frame(width: 70, alignment: .trailing)
                            .monospacedDigit()
                    }

                    HStack {
                        Text("Maximum")
                            .frame(width: 80, alignment: .leading)
                        Slider(value: Binding(
                            get: { SliderHelpers.indexForActivation(settings.randomMaxInterval) },
                            set: {
                                let newValue = SliderHelpers.activationSteps()[Int($0)]
                                settings.randomMaxInterval = newValue
                                // Ensure min is always <= max
                                if settings.randomMinInterval > newValue {
                                    settings.randomMinInterval = newValue
                                }
                            }
                        ), in: 0...Double(SliderHelpers.activationSteps().count - 1), step: 1)
                        Text(SliderHelpers.formatActivation(settings.randomMaxInterval))
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
                            TextField("Label:", text: $scheduledTime.name)
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
}
