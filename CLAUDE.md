# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pause is a macOS application built with SwiftUI and Swift 5.0. The project targets macOS 15.3+ and uses Xcode 16.4 for development.

## Build and Test Commands

### Building the Application
```bash
# Build the app (Debug configuration)
xcodebuild -project Pause.xcodeproj -scheme Pause -configuration Debug build

# Build the app (Release configuration)
xcodebuild -project Pause.xcodeproj -scheme Pause -configuration Release build

# Clean build artifacts
xcodebuild -project Pause.xcodeproj -scheme Pause clean
```

### Running Tests
```bash
# Run all tests
xcodebuild test -project Pause.xcodeproj -scheme Pause

# Run only unit tests (PauseTests)
xcodebuild test -project Pause.xcodeproj -scheme Pause -only-testing:PauseTests

# Run only UI tests (PauseUITests)
xcodebuild test -project Pause.xcodeproj -scheme Pause -only-testing:PauseUITests

# Run a specific test
xcodebuild test -project Pause.xcodeproj -scheme Pause -only-testing:PauseTests/PauseTests/example
```

### Development Workflow
```bash
# Open project in Xcode
open Pause.xcodeproj

# Build and run from command line
xcodebuild -project Pause.xcodeproj -scheme Pause -configuration Debug
```

## Architecture

### Application Overview
Pause is a meditation/mindfulness app that triggers fullscreen breathing sessions either manually (via global hotkey) or automatically based on schedules. The app uses a singleton-based architecture with SwiftUI for the UI layer.

### Core Components

#### State Management (Singleton Pattern)
All state is managed through three shared singletons:
- **`AppState.shared`**: Controls pause mode state, timer logic, audio playback, and fullscreen window management
- **`Settings.shared`**: Manages user preferences backed by UserDefaults with `@Published` properties
- **`ActivationScheduler.shared`**: Handles three independent activation modes (repeated, random, scheduled)
- **`GlobalHotkeyManager.shared`**: Registers Control-Command-0 hotkey using Carbon APIs

#### Key Files
- **`PauseApp.swift`**: App entry point with `@NSApplicationDelegateAdaptor` to prevent termination when windows close
- **`ContentView.swift`**: SwiftUI view that switches between settings UI and fullscreen breathing view based on `AppState.isPauseMode`
- **`AppState.swift`**: Core session logic including timer management, audio playback (AVAudioPlayer), fullscreen transitions, and session tracking
- **`Settings.swift`**: Persistence layer using `@Published` properties that auto-save to UserDefaults on change
- **`ActivationScheduler.swift`**: Timer orchestration for three activation modes that can run simultaneously
- **`GlobalHotkeyManager.swift`**: Carbon-based global hotkey registration (uses legacy Carbon HIToolbox APIs)

#### Application Lifecycle
1. App initializes `GlobalHotkeyManager` and `ActivationScheduler` in `PauseApp.init()`
2. `AppDelegate` prevents app termination when windows close (allows background hotkey operation)
3. Hotkey or timer triggers `AppState.triggerPauseMode()`
4. If not in pause mode: creates/finds window, enters fullscreen, starts timer and optional audio
5. If already in pause mode: exits early (spacebar also exits early)
6. Session completion increments `Settings.completedSessions` and `completedSessionTime`

#### Activation Modes (Independent, Can Run Simultaneously)
- **Repeated**: Fires every N minutes using a repeating Timer
- **Random**: Fires at random intervals within min-max range, reschedules itself after each trigger
- **Scheduled**: Fires at specific times of day, automatically reschedules for next day

### Project Structure
- **Pause/**: Main application target containing app source code
  - Core files: `PauseApp.swift`, `ContentView.swift`, `AppState.swift`, `Settings.swift`
  - Managers: `GlobalHotkeyManager.swift`, `ActivationScheduler.swift`
  - `Pause.entitlements`: App sandbox entitlements configuration
  - `Assets.xcassets/`: App icons and visual assets
  - Audio files: `pad.mp3`, `pad2.mp3`, `keys.mp3`, `rain.mp3`, `walking.mp3`, `birds.mp3`, `waves.mp3`

- **PauseTests/**: Unit test target using Swift Testing framework
  - Tests are written using the modern `@Test` macro (not XCTest)

- **PauseUITests/**: UI test target for automated UI testing

### Key Configuration Details
- **Bundle Identifier**: `pause.Pause`
- **Swift Version**: 5.0
- **Deployment Target**: macOS 15.3
- **Code Signing**: Automatic
- **App Groups**: Enabled via `REGISTER_APP_GROUPS = YES`

### Entitlements
The app runs in a sandboxed environment with:
- App sandbox enabled (`com.apple.security.app-sandbox`)
- Read-only access to user-selected files (`com.apple.security.files.user-selected.read-only`)

### Testing Framework
This project uses Swift Testing (the modern Swift testing framework) rather than XCTest. Tests use the `@Test` attribute and `#expect()` for assertions, not XCTest's `XCTestCase` and `XCTAssert*()` methods.

## Development Notes

### Adding New Swift Files
New `.swift` files added to the `Pause/` directory will be automatically included in the build due to the project using `PBXFileSystemSynchronizedRootGroup` (Xcode's modern file system synchronization).

### SwiftUI Previews
Views include `#Preview` macros for live previews in Xcode Canvas during development.

### Build Configurations
The project has two build configurations:
- **Debug**: Includes debug symbols, testability enabled, optimization level 0
- **Release**: Optimized for performance with whole module optimization
