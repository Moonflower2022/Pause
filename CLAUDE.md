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

### Project Structure
- **Pause/**: Main application target containing app source code
  - `PauseApp.swift`: App entry point using `@main` SwiftUI App lifecycle
  - `ContentView.swift`: Root view of the application
  - `Pause.entitlements`: App sandbox entitlements configuration
  - `Assets.xcassets/`: App icons and visual assets

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
