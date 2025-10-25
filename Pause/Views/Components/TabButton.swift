//
//  TabButton.swift
//  Pause
//
//  Custom tab button for icon-based navigation
//

import SwiftUI

struct TabButton: View {
    let icon: String
    let label: String
    let tag: Int
    @Binding var selectedTab: Int

    var body: some View {
        Button(action: {
            selectedTab = tag
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(selectedTab == tag ? .accentColor : .secondary)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(selectedTab == tag ? .primary : .secondary)
            }
            .frame(width: 70)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(selectedTab == tag ? Color.accentColor.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
