//
//  SessionSettingsTab.swift
//  Pause
//
//  Session duration and display settings
//

import SwiftUI

struct SessionSettingsTab: View {
    @ObservedObject var settings = Settings.shared

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Pause Duration")
                        .frame(width: 140, alignment: .leading)
                    Slider(value: Binding(
                        get: { SliderHelpers.indexForDuration(settings.pauseDuration) },
                        set: { settings.pauseDuration = SliderHelpers.durationSteps()[Int($0)] }
                    ), in: 0...Double(SliderHelpers.durationSteps().count - 1), step: 1)
                    Text(SliderHelpers.formatDuration(settings.pauseDuration))
                        .frame(width: 50, alignment: .trailing)
                        .monospacedDigit()
                }

                HStack {
                    Text("Time Variance")
                        .frame(width: 140, alignment: .leading)
                    Slider(value: Binding(
                        get: { SliderHelpers.indexForVariance(settings.pauseVariance) },
                        set: { settings.pauseVariance = SliderHelpers.varianceSteps()[Int($0)] }
                    ), in: 0...Double(SliderHelpers.varianceSteps().count - 1), step: 1)
                    Text(settings.pauseVariance == 0 ? "None" : "±\(SliderHelpers.formatDuration(settings.pauseVariance))")
                        .frame(width: 50, alignment: .trailing)
                        .monospacedDigit()
                }

                HStack {
                    Text("Snooze Duration")
                        .frame(width: 140, alignment: .leading)
                    Slider(value: Binding(
                        get: { SliderHelpers.indexForActivation(settings.snoozeDuration) },
                        set: { settings.snoozeDuration = SliderHelpers.activationSteps()[Int($0)] }
                    ), in: 0...Double(SliderHelpers.activationSteps().count - 1), step: 1)
                    Text(SliderHelpers.formatActivation(settings.snoozeDuration))
                        .frame(width: 50, alignment: .trailing)
                        .monospacedDigit()
                }
            } header: {
                Text("Timing")
            } footer: {
                Text("Snooze duration determines how long to delay when pressing the snooze key during a session.")
                    .font(.caption)
            }

            Section {
                HStack {
                    Text("Display Text")
                        .frame(width: 140, alignment: .leading)
                    TextField("", text: $settings.sessionDisplayText)
                        .textFieldStyle(.roundedBorder)
                }
            } header: {
                Text("Appearance")
            } footer: {
                Text("Text displayed during meditation sessions. Scheduled activations and snoozes will show their custom labels instead.")
                    .font(.caption)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}
