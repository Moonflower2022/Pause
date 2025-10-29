//
//  GeneralSettingsTab.swift
//  Pause
//
//  General settings tab for menu bar and appearance
//

import SwiftUI

struct GeneralSettingsTab: View {
    @ObservedObject var settings = Settings.shared

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
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}
