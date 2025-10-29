# GEMINI.md

## Project Overview

This project contains a native macOS meditation app called **Pause** and its accompanying marketing website.

### Pause macOS App

**Pause** is a SwiftUI-based application that provides immersive, fullscreen breathing sessions. It's designed to help users take mindful breaks throughout their day.

**Key Features:**

*   **Immersive Sessions:** Fullscreen breathing exercises with animated gradients.
*   **Flexible Activation:** Sessions can be triggered manually via a global hotkey, at repeated intervals, at random intervals, or at specific scheduled times.
*   **Audio Experience:** Includes a variety of ambient sounds and start/end cues.
*   **Customization:** Users can customize session duration, display text, hotkeys, and more.
*   **"No-Go" Times:** Users can define specific times when sessions should not be automatically activated.

**Architecture:**

The app is built with SwiftUI and uses a singleton pattern for managing application state and settings.

*   `PauseApp.swift`: The main entry point for the application.
*   `AppState.swift`: A singleton that manages the core application state, including the session lifecycle, audio playback, and fullscreen mode.
*   `Settings.swift`: A singleton that manages user preferences, persisting them to `UserDefaults`.
*   `ActivationScheduler.swift`: Orchestrates the various activation modes (repeated, random, and scheduled).
*   `GlobalHotkeyManager.swift`: Handles the registration of the global hotkey for starting sessions.
*   `MenuBarManager.swift`: Manages the app's menu bar icon and countdown timer.

### Website

The `website/` directory contains the source code for the marketing website for the Pause app.

**Tech Stack:**

*   **Vue.js 3:** A progressive JavaScript framework.
*   **TypeScript:** For type-safe development.
*   **Vite:** A modern frontend build tool.

The website is a single-page application that showcases the features of the Pause app and provides a download link.

## Building and Running

### Pause macOS App

To build and run the macOS app, you'll need Xcode 16.4 or later.

1.  Clone the repository.
2.  Open `Pause.xcodeproj` in Xcode.
3.  Press `⌘R` to build and run the app.

**Command-line builds:**

```bash
# Build (Debug)
xcodebuild -project Pause.xcodeproj -scheme Pause -configuration Debug build

# Build (Release)
xcodebuild -project Pause.xcodeproj -scheme Pause -configuration Release build

# Run all tests
xcodebuild test -project Pause.xcodeproj -scheme Pause
```

### Website

To run the website locally, you'll need Node.js 20.19.0 or later.

1.  Navigate to the `website/` directory.
2.  Install dependencies: `npm install`
3.  Start the development server: `npm run dev`

**Other available scripts:**

*   `npm run build`: Build for production.
*   `npm run preview`: Preview the production build locally.
*   `npm run lint`: Run linters.
*   `npm run format`: Format code with Prettier.

## Development Conventions

### Pause macOS App

*   **SwiftUI:** The app is built entirely with SwiftUI.
*   **Singleton Pattern:** The app uses singletons for managing global state (`AppState`) and settings (`Settings`).
*   **Swift Testing:** The project uses the modern Swift Testing framework, not XCTest.
*   **Global Hotkeys:** The app uses the Carbon framework for registering global hotkeys.
*   **Sparkle:** The app uses the Sparkle framework for automatic updates.

### Website

*   **Vue.js 3:** The website is built with Vue.js 3 and the Composition API.
*   **TypeScript:** All code is written in TypeScript.
*   **Vite:** The project uses Vite for development and builds.
*   **ESLint and Prettier:** The project uses ESLint for linting and Prettier for code formatting.
*   **Responsive Design:** The website is fully responsive and designed to work on desktop, tablet, and mobile devices.
