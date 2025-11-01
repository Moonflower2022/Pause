//
//  DoomScrollSettingsTab.swift
//  Pause
//
//  Settings for doom scrolling detection
//

import SwiftUI

struct DoomScrollSettingsTab: View {
    @ObservedObject var settings = Settings.shared

    var body: some View {
        Form {
            // Main toggle
            Section {
                Toggle("Detect Doom Scrolling", isOn: $settings.doomScrollEnabled)
                    .toggleStyle(.switch)
            } header: {
                Text("Doom Scroll Detection")
            } footer: {
                Text("Automatically triggers a pause session when mindless scrolling patterns are detected (e.g., Reddit, Twitter, Instagram, memes, etc.).")
                    .font(.caption)
            }

            if settings.doomScrollEnabled {
                // Velocity threshold
                Section {
                    HStack {
                        Text("Velocity Threshold")
                            .frame(width: 140, alignment: .leading)
                        Slider(value: Binding(
                            get: { Double(settings.doomScrollVelocityThreshold) },
                            set: { settings.doomScrollVelocityThreshold = Int($0) }
                        ), in: 10...100, step: 5)
                        Text("\(settings.doomScrollVelocityThreshold)/min")
                            .frame(width: 70, alignment: .trailing)
                            .monospacedDigit()
                    }
                } header: {
                    Text("High Velocity")
                } footer: {
                    Text("Minimum number of forward actions (scroll down, down arrow, right arrow) per minute. Current: \(settings.doomScrollVelocityThreshold) actions/min.")
                        .font(.caption)
                }

                // Directionality threshold
                Section {
                    HStack {
                        Text("Directionality Threshold")
                            .frame(width: 140, alignment: .leading)
                        Slider(value: $settings.doomScrollDirectionalityThreshold, in: 0.5...0.99, step: 0.05)
                        Text("\(Int(settings.doomScrollDirectionalityThreshold * 100))%")
                            .frame(width: 70, alignment: .trailing)
                            .monospacedDigit()
                    }
                } header: {
                    Text("Strong Directionality")
                } footer: {
                    Text("Minimum percentage of forward vs. backward actions. Current: \(Int(settings.doomScrollDirectionalityThreshold * 100))% forward.")
                        .font(.caption)
                }

                // Pause threshold
                Section {
                    HStack {
                        Text("Pause Threshold")
                            .frame(width: 140, alignment: .leading)
                        Slider(value: $settings.doomScrollPauseThreshold, in: 0.5...5.0, step: 0.1)
                        Text("\(String(format: "%.1f", settings.doomScrollPauseThreshold))s")
                            .frame(width: 70, alignment: .trailing)
                            .monospacedDigit()
                    }
                } header: {
                    Text("Minimal Pauses")
                } footer: {
                    Text("Maximum median gap between actions (in seconds). Current: \(String(format: "%.1f", settings.doomScrollPauseThreshold))s median gap.")
                        .font(.caption)
                }

                // Window duration
                Section {
                    HStack {
                        Text("Detection Window")
                            .frame(width: 140, alignment: .leading)
                        Slider(value: Binding(
                            get: { Double(settings.doomScrollWindowDuration) },
                            set: { settings.doomScrollWindowDuration = Int($0) }
                        ), in: 1...10, step: 1)
                        Text("\(settings.doomScrollWindowDuration) min")
                            .frame(width: 70, alignment: .trailing)
                            .monospacedDigit()
                    }
                } header: {
                    Text("Rolling Window")
                } footer: {
                    Text("Time window to analyze scrolling behavior. Longer windows are less sensitive to brief scrolling bursts. Current: \(settings.doomScrollWindowDuration) minutes.")
                        .font(.caption)
                }

                // Summary
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Detection triggers when ALL conditions are met:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("• Velocity ≥ \(settings.doomScrollVelocityThreshold) actions/min")
                            .font(.caption)
                        Text("• Directionality ≥ \(Int(settings.doomScrollDirectionalityThreshold * 100))% forward")
                            .font(.caption)
                        Text("• Median pause ≤ \(String(format: "%.1f", settings.doomScrollPauseThreshold))s")
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Current Detection Criteria")
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}
