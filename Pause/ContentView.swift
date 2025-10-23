//
//  ContentView.swift
//  Pause
//
//  Created by Harrison Qian on 10/22/25.
//

import SwiftUI

struct ContentView: View {
    @State private var message: String = "Press Control-Command-0 (works globally!)"
    @State private var messageCount: Int = 0
    @StateObject private var hotkeyManager = GlobalHotkeyManager()

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("Triggered \(messageCount) times")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("This shortcut works even when the app is in the background")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 200)
        .onAppear {
            // Set up the hotkey callback
            hotkeyManager.onHotkeyPressed = {
                handleShortcut()
            }
        }
    }

    private func handleShortcut() {
        messageCount += 1
        message = "Global keyboard shortcut triggered! 🎉"

        // Reset message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            message = "Press Control-Command-0 (works globally!)"
        }
    }
}

#Preview {
    ContentView()
}
