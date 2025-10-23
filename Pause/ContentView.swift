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
    @State private var message: String = "Press Control-Command-0 (works globally!)"
    @ObservedObject var appState = AppState.shared

    var body: some View {
        ZStack {
            if appState.isPauseMode {
                // Fullscreen breathing view
                breathingView
            } else {
                // Normal view
                normalView
            }
        }
        .onChange(of: appState.isPauseMode) { _, newValue in
            if !newValue {
                // Pause mode just ended, show completion message
                message = "Pause session completed ✨"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    message = "Press Control-Command-0 (works globally!)"
                }
            }
        }
    }

    private var normalView: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("Triggered \(appState.messageCount) times")
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
