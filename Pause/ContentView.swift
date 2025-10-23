//
//  ContentView.swift
//  Pause
//
//  Created by Harrison Qian on 10/22/25.
//

import SwiftUI

struct ContentView: View {
    @State private var message: String = "Press Control-Command-0"
    @State private var messageCount: Int = 0

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(message)
                .font(.headline)
            Text("Triggered \(messageCount) times")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(minWidth: 300, minHeight: 200)
        // Invisible button to capture keyboard shortcut
        Button("") {
            handleShortcut()
        }
        .keyboardShortcut("0", modifiers: [.control, .command])
        .hidden()
    }

    private func handleShortcut() {
        messageCount += 1
        message = "Keyboard shortcut triggered! 🎉"

        // Reset message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            message = "Press Control-Command-0"
        }
    }
}

#Preview {
    ContentView()
}
