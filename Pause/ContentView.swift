//
//  ContentView.swift
//  Pause
//
//  Created by Harrison Qian on 10/22/25.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var appState = AppState.shared
    @ObservedObject var settings = Settings.shared

    var body: some View {
        ZStack {
            if appState.isPauseMode {
                // Fullscreen breathing view
                BreathingView()
            } else {
                // Settings view
                SettingsView()
            }
        }
    }
}

struct SettingsView: View {
    @ObservedObject var settings = Settings.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header - three column layout
            HStack(alignment: .center, spacing: 40) {
                // Left: Session stats
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sessions: \(settings.completedSessions)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Time: \(SliderHelpers.formatSessionTime(settings.completedSessionTime))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(minWidth: 120)

                // Center: App title
                VStack(spacing: 8) {
                    Text("Pause")
                        .font(.system(size: 32, weight: .light))
                    Text("Press \(settings.getActivateHotkeyString()) to start")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Right: Next activation countdown
                NextActivationCountdown()
                    .frame(minWidth: 120)
            }
            .padding(.top, 30)
            .padding(.bottom, 20)

            Divider()

            // Icon-based tab navigation
            HStack(spacing: 16) {
                TabButton(icon: "gearshape", label: "General", tag: 0, selectedTab: $settings.selectedTab)
                TabButton(icon: "display", label: "Session", tag: 1, selectedTab: $settings.selectedTab)
                TabButton(icon: "speaker.wave.2", label: "Audio", tag: 2, selectedTab: $settings.selectedTab)
                TabButton(icon: "clock", label: "Activation", tag: 3, selectedTab: $settings.selectedTab)
                TabButton(icon: "command", label: "Shortcuts", tag: 4, selectedTab: $settings.selectedTab)
            }
            .padding(.vertical, 16)

            Divider()

            // Content area
            Group {
                switch settings.selectedTab {
                case 0:
                    GeneralSettingsTab()
                case 1:
                    SessionSettingsTab()
                case 2:
                    AudioSettingsTab()
                case 3:
                    ActivationSettingsTab()
                case 4:
                    ShortcutsSettingsTab()
                default:
                    GeneralSettingsTab()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 600, minHeight: 550)
        .textSelection(.enabled)
    }
}

#Preview {
    ContentView()
}
