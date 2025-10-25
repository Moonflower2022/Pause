//
//  AudioSettingsTab.swift
//  Pause
//
//  Audio settings for ambient sounds and start/end chimes
//

import SwiftUI

struct AudioSettingsTab: View {
    @ObservedObject var settings = Settings.shared

    var body: some View {
        Form {
            Section {
                Toggle("Enable Ambient Sound", isOn: $settings.soundEnabled)

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
                Text("Ambient Audio")
            }

            Section {
                Toggle("Enable Start Sound", isOn: $settings.startSoundEnabled)

                HStack {
                    Text("Volume")
                        .frame(width: 140, alignment: .leading)
                    Slider(value: $settings.startSoundVolume, in: 0...1, step: 0.1)
                    Text("\(Int(settings.startSoundVolume * 100))%")
                        .frame(width: 50, alignment: .trailing)
                        .monospacedDigit()
                }
                .disabled(!settings.startSoundEnabled)
            } header: {
                Text("Start Sound")
            }

            Section {
                Toggle("Enable End Sound", isOn: $settings.endSoundEnabled)

                HStack {
                    Text("Volume")
                        .frame(width: 140, alignment: .leading)
                    Slider(value: $settings.endSoundVolume, in: 0...1, step: 0.1)
                    Text("\(Int(settings.endSoundVolume * 100))%")
                        .frame(width: 50, alignment: .trailing)
                        .monospacedDigit()
                }
                .disabled(!settings.endSoundEnabled)
            } header: {
                Text("End Sound")
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}
