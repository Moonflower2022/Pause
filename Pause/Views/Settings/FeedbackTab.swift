//
//  FeedbackTab.swift
//  Pause
//
//  Created by Claude on 10/28/25.
//

import SwiftUI
import AppKit

struct FeedbackTab: View {
    @ObservedObject var settings = Settings.shared
    @State private var showCopiedAlert = false

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Help make Pause better!")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Your feedback helps improve Pause for everyone. Choose your preferred way to share thoughts, report bugs, or suggest features.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section {
                Button(action: {
                    let url = URL(string: "https://github.com/Moonflower2022/Pause/issues")!
                    NSWorkspace.shared.open(url)
                }) {
                    HStack {
                        Image(systemName: "ladybug")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("GitHub Issues")
                                .font(.body)
                            Text("Report bugs or request features")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.vertical, 4)

                Button(action: {
                    let subject = "Pause App Feedback"
                    let body = "\n\n---\nSystem Info:\n\(getSystemInfo())"
                    let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    let url = URL(string: "mailto:harrisonq125@gmail.com?subject=\(encodedSubject)&body=\(encodedBody)")!
                    NSWorkspace.shared.open(url)
                }) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Email Feedback")
                                .font(.body)
                            Text("Send feedback via email")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.vertical, 4)

                Button(action: {
                    let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLScW_Iycy4GWWOVnxGP5z7qnB-CbKSJ4cFZe5V5G9G6Xf0rmuw/viewform?usp=publish-editor")!
                    NSWorkspace.shared.open(url)
                }) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Google Form")
                                .font(.body)
                            Text("Fill out a quick feedback form")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.vertical, 4)
            } header: {
                Text("Feedback Channels")
            }

            Section {
                Button(action: {
                    let systemInfo = getSystemInfo()
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(systemInfo, forType: .string)
                    showCopiedAlert = true

                    // Hide alert after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showCopiedAlert = false
                    }
                }) {
                    HStack {
                        Image(systemName: "doc.on.clipboard")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Copy System Info")
                                .font(.body)
                            if showCopiedAlert {
                                Text("Copied to clipboard!")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else {
                                Text("Copy debug information for bug reports")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Image(systemName: showCopiedAlert ? "checkmark" : "doc.on.doc")
                            .font(.caption)
                            .foregroundColor(showCopiedAlert ? .green : .secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.vertical, 4)
            } header: {
                Text("Debug Tools")
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    private func getSystemInfo() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let osVersionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"

        return """
        App Version: \(appVersion) (Build \(buildNumber))
        macOS Version: \(osVersionString)
        """
    }
}
