//
//  DetectionSettingsTab.swift
//  Pause
//
//  Settings for overworking detection based on input latency thresholds
//

import SwiftUI

struct DetectionSettingsTab: View {
    @ObservedObject var settings = Settings.shared

    var body: some View {
        Form {
            // Main detection toggle and logic
            Section {
                Toggle("Enable Detection", isOn: $settings.detectionEnabled)
                    .toggleStyle(.switch)

                if settings.detectionEnabled {
                    Toggle("Require Both Thresholds", isOn: $settings.andEnabled)
                        .toggleStyle(.switch)
                }
            } header: {
                Text("Overworking Detection")
            } footer: {
                if settings.detectionEnabled {
                    if settings.andEnabled {
                        Text("Pause will activate when both thresholds are surpassed")
                            .font(.caption)
                    } else {
                        Text("Pause will activate when either threshold is surpassed")
                            .font(.caption)
                    }
                } else {
                    Text("Detection is disabled. Configure thresholds below to detect overworking patterns.")
                        .font(.caption)
                }
            }

            // First threshold
            if settings.detectionEnabled {
                Section {
                    HStack {
                        Text("Input Latency")
                            .frame(width: 140, alignment: .leading)
                        Slider(value: $settings.detectionLatency1, in: 0.1...5.0, step: 0.1)
                        Text("\(String(format: "%.1f", settings.detectionLatency1))s")
                            .frame(width: 50, alignment: .trailing)
                            .monospacedDigit()
                    }

                    HStack {
                        Text("Count Threshold")
                            .frame(width: 140, alignment: .leading)
                        Slider(value: Binding(
                            get: { Double(settings.detectionCountThreshold1) },
                            set: { settings.detectionCountThreshold1 = Int($0) }
                        ), in: 10...200, step: 5)
                        Text("\(settings.detectionCountThreshold1)")
                            .frame(width: 50, alignment: .trailing)
                            .monospacedDigit()
                    }
                } header: {
                    Text("Threshold 1")
                } footer: {
                    Text("Triggers when \(settings.detectionCountThreshold1) inputs occur with less than \(String(format: "%.1f", settings.detectionLatency1))s between them")
                        .font(.caption)
                }
            }

            // Second threshold
            if settings.detectionEnabled {
                Section {
                    HStack {
                        Text("Input Latency")
                            .frame(width: 140, alignment: .leading)
                        Slider(value: $settings.detectionLatency2, in: 0.1...5.0, step: 0.1)
                        Text("\(String(format: "%.1f", settings.detectionLatency2))s")
                            .frame(width: 50, alignment: .trailing)
                            .monospacedDigit()
                    }

                    HStack {
                        Text("Count Threshold")
                            .frame(width: 140, alignment: .leading)
                        Slider(value: Binding(
                            get: { Double(settings.detectionCountThreshold2) },
                            set: { settings.detectionCountThreshold2 = Int($0) }
                        ), in: 10...200, step: 5)
                        Text("\(settings.detectionCountThreshold2)")
                            .frame(width: 50, alignment: .trailing)
                            .monospacedDigit()
                    }
                } header: {
                    Text("Threshold 2")
                } footer: {
                    Text("Triggers when \(settings.detectionCountThreshold2) inputs occur with less than \(String(format: "%.1f", settings.detectionLatency2))s between them")
                        .font(.caption)
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}
