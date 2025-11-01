//
//  ActivationSettingsTab.swift
//  Pause
//
//  Activation settings for repeated, random, and scheduled timers
//

import SwiftUI

struct ActivationSettingsTab: View {
    @ObservedObject var settings = Settings.shared
    @State private var showingAppPicker = false

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
            } header: {
                Text("Scheduled Activation")
            } footer: {
                if settings.scheduledEnabled {
                    Text("Pause will trigger at the specified times each day")
                        .font(.caption)
                } else {
                    Text("Scheduled activation is disabled. Times below will not trigger.")
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

            // App Launch Activation
            Section {
                Toggle("Activate on App Launch", isOn: $settings.appLaunchEnabled)
                    .toggleStyle(.switch)

                if settings.appLaunchEnabled {
                    ForEach($settings.monitoredApps) { $app in
                        VStack(alignment: .leading, spacing: 8) {
                            // App name and remove button
                            HStack {
                                Text(app.name)
                                    .font(.headline)
                                TextField("", text: Binding(
                                    get: { app.customMessage ?? "Just Breathe" },
                                    set: { app.customMessage = $0.isEmpty ? nil : $0 }
                                ))
                                .textFieldStyle(.roundedBorder)
                                Button("Remove") {
                                    settings.monitoredApps.removeAll { $0.id == app.id }
                                }
                                .buttonStyle(.borderless)
                                .foregroundColor(.red)
                            }

                            // Delay slider
                            HStack {
                                Text("Delay:")
                                    .frame(width: 80, alignment: .leading)
                                    .font(.caption)
                                Slider(value: $app.activationDelay, in: 0...30, step: 1)
                                Text("\(Int(app.activationDelay))s")
                                    .frame(width: 40, alignment: .trailing)
                                    .monospacedDigit()
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    Button("Add App...") {
                        showingAppPicker = true
                    }
                }
            } header: {
                Text("App Launch Activation")
            } footer: {
                if settings.appLaunchEnabled {
                    Text("Pause will activate automatically when any of the listed apps are launched. Perfect for games or distracting apps.")
                        .font(.caption)
                } else {
                    Text("When enabled, you can specify apps that will trigger a pause session when launched.")
                        .font(.caption)
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .sheet(isPresented: $showingAppPicker) {
            AppPickerView { app in
                // Check if app is already in the list
                if !settings.monitoredApps.contains(where: { $0.bundleIdentifier == app.bundleIdentifier }) {
                    settings.monitoredApps.append(app)
                }
                showingAppPicker = false
            }
        }
    }
}

// App Picker Sheet
struct AppPickerView: View {
    let onSelect: (MonitoredApp) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Select an Application")
                .font(.headline)

            Text("Choose an app from your Applications folder")
                .font(.caption)
                .foregroundColor(.secondary)

            Button("Choose from /Applications...") {
                let panel = NSOpenPanel()
                panel.canChooseFiles = true
                panel.canChooseDirectories = false
                panel.allowsMultipleSelection = false
                panel.directoryURL = URL(fileURLWithPath: "/Applications")
                panel.allowedContentTypes = [.application]

                if panel.runModal() == .OK, let url = panel.url {
                    if let bundle = Bundle(url: url),
                       let bundleIdentifier = bundle.bundleIdentifier,
                       let appName = bundle.infoDictionary?["CFBundleName"] as? String {
                        let app = MonitoredApp(
                            bundleIdentifier: bundleIdentifier,
                            name: appName,
                            iconPath: url.path
                        )
                        onSelect(app)
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding(40)
        .frame(width: 400, height: 200)
    }
}
