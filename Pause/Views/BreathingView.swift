//
//  BreathingView.swift
//  Pause
//
//  Extracted from ContentView.swift
//

import SwiftUI

struct BreathingView: View {
    @ObservedObject var appState = AppState.shared

    var body: some View {
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
                Text(appState.currentDisplayText)
                    .font(.system(size: 72, weight: .light, design: .rounded))
                    .foregroundColor(.white)

                // Breathing circle animation
                TimelineView(.animation) { context in
                    let scale = calculateBreathingScale(date: context.date)

                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .scaleEffect(scale)
                }

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
            .textSelection(.enabled)
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private func calculateBreathingScale(date: Date) -> Double {
        // Breathing cycle: 2s inhale + 3s exhale = 5s total
        let inhaleDuration = 2.0
        let exhaleDuration = 3.0
        let totalCycleDuration = inhaleDuration + exhaleDuration

        // Calculate position in the breathing cycle
        let timeInCycle = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: totalCycleDuration)

        let scale: Double
        if timeInCycle < inhaleDuration {
            // Inhale phase (0s to 2s): grow from 0.8 to 1.2
            let progress = timeInCycle / inhaleDuration
            // Use ease-in-out for smooth breathing
            let eased = (1.0 - cos(progress * .pi)) / 2.0
            scale = 0.8 + (eased * 0.4)
        } else {
            // Exhale phase (2s to 5s): shrink from 1.2 to 0.8
            let progress = (timeInCycle - inhaleDuration) / exhaleDuration
            // Use ease-in-out for smooth breathing
            let eased = (1.0 - cos(progress * .pi)) / 2.0
            scale = 1.2 - (eased * 0.4)
        }

        return scale
    }
}

#Preview {
    BreathingView()
}
