//
//  GeneralSettingsTab.swift
//  Pause
//
//  General settings tab for menu bar and appearance
//

import SwiftUI

struct GeneralSettingsTab: View {
    @ObservedObject var settings = Settings.shared
    @State private var showingResetAlert = false

    var body: some View {
        Form {
            Section {
                Toggle("Show in Menu Bar", isOn: $settings.showInMenuBar)

                Toggle("Timer Instead of Icon", isOn: $settings.menuBarShowTimer)
                    .disabled(!settings.showInMenuBar)
            } header: {
                Text("Appearance")
            } footer: {
                if settings.showInMenuBar {
                    Text("When enabled, the menu bar shows a countdown timer to the next activation instead of an icon.")
                        .font(.caption)
                }
            }

            Section {
                Button("Reset All Settings") {
                    showingResetAlert = true
                }
                .foregroundColor(.red)
            } header: {
                Text("Reset")
            } footer: {
                Text("Reset all settings to their default values. This will not reset your session statistics.")
                    .font(.caption)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .alert("Reset All Settings?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                settings.resetAllSettings()
            }
        } message: {
            Text("This will reset all settings to their default values. Your session statistics will be preserved. This action cannot be undone.")
        }
    }
}
