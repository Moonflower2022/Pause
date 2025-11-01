//
//  DetectionSettingsTab.swift
//  Pause
//
//  Settings for input detection and activation delay
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

                if let lastInput = detector.lastInputTime {
                    HStack {
                        Text("Last Input")
                            .frame(width: 180, alignment: .leading)
                        Spacer()
                        Text(lastInput, style: .relative)
                            .monospacedDigit()
                            .foregroundColor(.secondary)
                    }
                }

                if !detector.hasInputMonitoringPermission {
                    Button("Open System Settings") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
            } header: {
                Text("System Status")
            } footer: {
                if detector.hasInputMonitoringPermission {
                    Text("Input detection is active and monitoring keyboard/mouse events.")
                        .font(.caption)
                } else {
                    Text("Input Monitoring permission is required. Grant permission in System Settings → Privacy & Security → Input Monitoring, then restart the app.")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            // Main detection toggle
            Section {
                Toggle("Prevent Activations During Typing", isOn: $settings.detectionEnabled)
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
            } header: {
                Text("Input Detection")
            } footer: {
                if settings.detectionEnabled {
                    Text("When you type or click, scheduled activations closer than \(settings.inputDelayBuffer) seconds will be delayed to \(settings.inputDelayBuffer) seconds. This prevents interruptions while actively working.")
                        .font(.caption)
                } else {
                    Text("When enabled, any keyboard or mouse input will delay upcoming activations to prevent interruptions while you're typing.")
                        .font(.caption)
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}
