//
//  GeneralSettingsTab.swift
//  Pause
//
//  General settings tab for menu bar and appearance
//

import SwiftUI

struct GeneralSettingsTab: View {
    @ObservedObject var settings = Settings.shared
    @ObservedObject var accessibilityManager = AccessibilityPermissionManager.shared

    var body: some View {
        Form {
            if !accessibilityManager.hasAccessibilityPermission {
                Section {
                    Button("Open System Settings") {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                    }
                } header: {
                    Text("Accessibility")
                } footer: {
                    Text("Accessibility permission is required to activate Pause. Grant permission in System Settings → Privacy & Security → Accessibility.")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

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
        .onAppear {
            accessibilityManager.refreshStatus()
        }
    }
}
