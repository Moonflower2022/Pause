//
//  ShortcutsSettingsTab.swift
//  Pause
//
//  Shortcuts settings with hotkey recorder
//

import SwiftUI
import Carbon.HIToolbox

struct ShortcutsSettingsTab: View {
    var body: some View {
        Form {
            Section {
                HotkeyRecorderView()
            } header: {
                Text("Global Hotkeys")
            } footer: {
                Text("Press the button below and then press your desired key combination")
                    .font(.caption)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

// Hotkey recorder view
struct HotkeyRecorderView: View {
    @ObservedObject var settings = Settings.shared
    @State private var isRecording = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Activate Session:")
                    .frame(width: 140, alignment: .leading)
                Text(settings.getHotkeyString())
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(6)

                Spacer()

                Button(action: {
                    isRecording = true
                }) {
                    HStack {
                        Image(systemName: isRecording ? "record.circle.fill" : "record.circle")
                            .foregroundColor(isRecording ? .red : .primary)
                        Text(isRecording ? "Press your key combination..." : "Record New Hotkey")
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .textSelection(.enabled)
        .background(
            // Invisible overlay to capture key events
            KeyEventHandlingView(isRecording: $isRecording) { keyCode, modifiers in
                if isRecording {
                    // Update settings with new hotkey
                    settings.hotkeyKeyCode = keyCode
                    settings.hotkeyModifiers = modifiers
                    isRecording = false
                }
            }
        )
    }
}

// NSView wrapper to capture key events
struct KeyEventHandlingView: NSViewRepresentable {
    @Binding var isRecording: Bool
    var onKeyPressed: (UInt32, UInt32) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = KeyCaptureView()
        view.onKeyPressed = onKeyPressed
        view.isRecordingBinding = $isRecording
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let keyView = nsView as? KeyCaptureView {
            keyView.isRecordingBinding = $isRecording

            // Auto-focus the view when recording starts
            if isRecording {
                DispatchQueue.main.async {
                    keyView.window?.makeFirstResponder(keyView)
                }
            }
        }
    }
}

class KeyCaptureView: NSView {
    var onKeyPressed: ((UInt32, UInt32) -> Void)?
    var isRecordingBinding: Binding<Bool>?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        guard isRecordingBinding?.wrappedValue == true else {
            super.keyDown(with: event)
            return
        }

        // Convert NSEvent modifiers to Carbon modifiers
        var carbonModifiers: UInt32 = 0
        if event.modifierFlags.contains(.control) {
            carbonModifiers |= UInt32(controlKey)
        }
        if event.modifierFlags.contains(.option) {
            carbonModifiers |= UInt32(optionKey)
        }
        if event.modifierFlags.contains(.shift) {
            carbonModifiers |= UInt32(shiftKey)
        }
        if event.modifierFlags.contains(.command) {
            carbonModifiers |= UInt32(cmdKey)
        }

        // Only accept if at least one modifier is pressed
        if carbonModifiers != 0 {
            onKeyPressed?(UInt32(event.keyCode), carbonModifiers)
        }
    }
}
