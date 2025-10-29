//
//  DetectionSettingsTab.swift
//  Pause
//
//  Settings for overworking detection based on input latency thresholds
//

import SwiftUI

struct DetectionSettingsTab: View {
    @ObservedObject var settings = Settings.shared
    @ObservedObject var detector = InputDetectionManager.shared

    var body: some View {
        Form {
            // System status
            Section {
                HStack {
                    Text("Input Monitoring Permission")
                        .frame(width: 180, alignment: .leading)
                    Spacer()
                    if detector.hasInputMonitoringPermission {
                        Text("✅ Granted")
                            .foregroundColor(.green)
                    } else {
                        Text("❌ Not Granted")
                            .foregroundColor(.red)
                    }
                }

                HStack {
                    Text("Events Received")
                        .frame(width: 180, alignment: .leading)
                    Spacer()
                    Text("\(detector.totalEventsReceived)")
                        .monospacedDigit()
                        .foregroundColor(detector.totalEventsReceived > 0 ? .green : .secondary)
                }

                if !detector.hasInputMonitoringPermission {
                    Button("Open System Settings") {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!)
                    }
                }
            } header: {
                Text("System Status")
            } footer: {
                if detector.hasInputMonitoringPermission {
                    Text("Input detection is active and monitoring keyboard/mouse events. Events received: \(detector.totalEventsReceived). Check Console.app for detailed logs (search for 'InputDetectionManager').")
                        .font(.caption)
                } else {
                    Text("Input Monitoring permission is required to monitor input events. Grant permission in System Settings → Privacy & Security → Input Monitoring, then restart the app.")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

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

                    HStack {
                        Text("Current Count")
                            .frame(width: 140, alignment: .leading)
                        Spacer()
                        Text("\(detector.currentCount1)")
                            .frame(width: 50, alignment: .trailing)
                            .monospacedDigit()
                            .foregroundColor(detector.currentCount1 >= settings.detectionCountThreshold1 ? .red : .primary)
                    }
                } header: {
                    Text("Threshold 1")
                } footer: {
                    Text("Triggers when \(settings.detectionCountThreshold1) inputs occur with less than \(String(format: "%.1f", settings.detectionLatency1))s between them. Current: \(detector.currentCount1)")
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

                    HStack {
                        Text("Current Count")
                            .frame(width: 140, alignment: .leading)
                        Spacer()
                        Text("\(detector.currentCount2)")
                            .frame(width: 50, alignment: .trailing)
                            .monospacedDigit()
                            .foregroundColor(detector.currentCount2 >= settings.detectionCountThreshold2 ? .red : .primary)
                    }
                } header: {
                    Text("Threshold 2")
                } footer: {
                    Text("Triggers when \(settings.detectionCountThreshold2) inputs occur with less than \(String(format: "%.1f", settings.detectionLatency2))s between them. Current: \(detector.currentCount2)")
                        .font(.caption)
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}
