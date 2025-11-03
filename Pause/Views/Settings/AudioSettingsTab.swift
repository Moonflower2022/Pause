//
//  AudioSettingsTab.swift
//  Pause
//
//  Audio settings for ambient sounds and start/end chimes
//

import SwiftUI
import AVFoundation

struct AudioSettingsTab: View {
    @ObservedObject var settings = Settings.shared
    @ObservedObject var appState = AppState.shared
    @State private var previewPlayer: AVAudioPlayer?

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

            // Sound Selection
            Section {
                ForEach(["random"] + appState.ambientSounds, id: \.self) { soundName in
                    HStack {
                        // Selection indicator
                        Image(systemName: settings.selectedAmbientSound == soundName ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(settings.selectedAmbientSound == soundName ? .blue : .secondary)
                            .onTapGesture {
                                settings.selectedAmbientSound = soundName
                                stopPreview()
                            }

                        // Sound name
                        Text(soundName.capitalized)
                            .onTapGesture {
                                settings.selectedAmbientSound = soundName
                                stopPreview()
                            }

                        Spacer()

                        // Preview button (only for actual sounds, not "random")
                        if soundName != "random" {
                            Button(action: {
                                if previewPlayer?.url?.lastPathComponent.replacingOccurrences(of: ".mp3", with: "") == soundName {
                                    // Already playing this sound, stop it
                                    stopPreview()
                                } else {
                                    // Play preview
                                    playPreview(soundName: soundName)
                                }
                            }) {
                                Image(systemName: previewPlayer?.url?.lastPathComponent.replacingOccurrences(of: ".mp3", with: "") == soundName ? "stop.circle.fill" : "play.circle.fill")
                                    .font(.title2)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            } header: {
                Text("Sound Selection")
            } footer: {
                Text("Choose a specific ambient sound or 'Random' to pick a different sound each session.")
                    .font(.caption)
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

    // MARK: - Preview Functions

    private func playPreview(soundName: String) {
        // Stop any currently playing preview
        stopPreview()

        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Could not find audio file: \(soundName).mp3")
            return
        }

        do {
            previewPlayer = try AVAudioPlayer(contentsOf: soundURL)
            previewPlayer?.volume = Float(settings.soundVolume)
            previewPlayer?.numberOfLoops = -1 // Loop for preview
            previewPlayer?.prepareToPlay()
            previewPlayer?.play()
            print("Previewing: \(soundName).mp3")
        } catch {
            print("Error playing preview: \(error.localizedDescription)")
        }
    }

    private func stopPreview() {
        previewPlayer?.stop()
        previewPlayer = nil
    }
}
