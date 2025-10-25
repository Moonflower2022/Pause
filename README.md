<p align="center">
  <h1 align="center">Pause</h1>
  <p align="center">
    A beautiful macOS meditation app for mindful breathing breaks throughout your day.
  </p>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-15.3+-blue.svg" alt="macOS 15.3+">
  <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" alt="Swift 5.0">
  <img src="https://img.shields.io/badge/SwiftUI-Native-green.svg" alt="SwiftUI">
</p>

---

## Overview

**Pause** is a native macOS meditation app that creates immersive fullscreen breathing sessions. Trigger sessions manually via global hotkey or automatically through flexible scheduling.

---

## ✨ Features

### Core Experience
- **Immersive fullscreen sessions** with gradient backgrounds and breathing animations
- **Global hotkey access** (default: `⌃⌘0`) - works even when app is backgrounded
- **Flexible duration** - 30 seconds to 10 hours (17 preset levels)
- **Session tracking** - Monitor completed sessions and total meditation time

### Audio
- **7 ambient sounds** - Pad, keys, rain, walking, birds, waves (randomly selected each session)
- **Start & end cues** - Gentle audio notifications for session boundaries
- **Volume control** - Independent sliders for ambient sounds and notification cues
- **Silence gaps** - Control pauses between ambient sound loops (0-30s)

### Automation
Three independent activation modes that run simultaneously:

1. **Repeated** - Fixed intervals (30s to 10h)
2. **Random** - Unpredictable intervals within min-max range
3. **Scheduled** - Specific daily times with custom labels (e.g., "Morning Reset" at 9:00 AM)

### Customization
- **Time variance** - Add ±0-120s randomness to session duration
- **Custom display text** - Set your own breathing prompts
- **Custom hotkeys** - Any modifier-key combination
- **Menu bar integration** - Optional icon or live countdown timer
- **Undo/redo** - Full history for scheduled times (⌘Z / ⌘⇧Z)

---

## 📋 Requirements

- **macOS** 15.3 or later
- **Xcode** 16.4, Swift 5.0 (for development)

---

## 🚀 Installation

### For Users
1. Download from [Releases](../../releases)
2. Drag `Pause.app` to `/Applications`
3. Launch and configure preferences
4. Grant accessibility permissions for global hotkey

### For Developers
```bash
git clone https://github.com/yourusername/Pause.git
cd Pause
open Pause.xcodeproj
# Press ⌘R to build and run
```

---

## 📖 Quick Start

1. Launch Pause
2. Set session duration in Session tab (default: 1 minute)
3. Press `⌃⌘0` anywhere to start a session
4. Breathe with the interface until timer completes
5. Press **Space** to exit early (won't count toward stats)

### Setting Up Automatic Sessions

Navigate to **Activation** tab:

- **Repeated**: Enable and set interval (e.g., every 60 minutes)
- **Random**: Enable and set min-max range (e.g., 30-120 minutes)
- **Scheduled**: Click "+" to add specific times with custom labels

All three modes can run simultaneously.

---

## 🔧 Building and Testing

```bash
# Build (Debug)
xcodebuild -project Pause.xcodeproj -scheme Pause -configuration Debug build

# Build (Release)
xcodebuild -project Pause.xcodeproj -scheme Pause -configuration Release build

# Run all tests
xcodebuild test -project Pause.xcodeproj -scheme Pause
```

**Note**: Uses modern **Swift Testing framework** (not XCTest).

---

## 🎨 Architecture

Built with SwiftUI and singleton-based state management:

- **AppState** - Session lifecycle, audio playback, fullscreen management
- **Settings** - UserDefaults-backed preferences with auto-persistence
- **ActivationScheduler** - Orchestrates three independent timer modes
- **GlobalHotkeyManager** - Carbon-based global hotkey registration
- **MenuBarManager** - Optional menu bar integration

### Project Structure
```
Pause/
├── Pause/
│   ├── PauseApp.swift              # App entry point
│   ├── ContentView.swift           # Root view (settings + breathing UI)
│   ├── AppState.swift              # Session state management
│   ├── Settings.swift              # Preferences & persistence
│   ├── ActivationScheduler.swift  # Timer orchestration
│   ├── GlobalHotkeyManager.swift  # Hotkey registration
│   ├── MenuBarManager.swift       # Menu bar integration
│   ├── Views/                      # SwiftUI components
│   ├── Utilities/                  # Helper utilities
│   └── Resources/                  # Audio files (.mp3)
├── PauseTests/                     # Unit tests
└── PauseUITests/                   # UI automation tests
```

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/YourFeature`
3. Commit changes with clear descriptions
4. Push to fork: `git push origin feature/YourFeature`
5. Open Pull Request

---

## 💬 Support

- **Bug Reports**: [Open an issue](../../issues)
- **Feature Requests**: [Start a discussion](../../discussions)

---

<p align="center">
  Built with ❤️ for macOS
</p>
