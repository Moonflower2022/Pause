//
//  ContentView.swift
//  Pause
//
//  Created by Harrison Qian on 10/22/25.
//

import SwiftUI
import AppKit
import AVFoundation

struct ContentView: View {
    @ObservedObject var appState = AppState.shared
    @ObservedObject var settings = Settings.shared

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
            // Header
            VStack(spacing: 8) {
                Text("Pause")
                    .font(.system(size: 32, weight: .light))
                Text("Press ⌃⌘0 to start")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 30)
            .padding(.bottom, 20)

            Divider()

            // Settings Form
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

            Spacer()

            // Footer
            Text("Sessions completed: \(appState.messageCount)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 20)
        }
        .frame(minWidth: 500, minHeight: 500)
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
        }
    }


    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

#Preview {
    ContentView()
}
