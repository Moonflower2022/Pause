# Pause

A macOS meditation and mindfulness app that helps you take regular breathing breaks throughout your day. Pause triggers fullscreen breathing sessions either manually via global hotkey or automatically based on customizable schedules.

## Features

### Core Functionality
- **Fullscreen Breathing Sessions**: Immersive fullscreen view with calming gradient background and breathing circle
- **Customizable Duration**: Set pause sessions from 10 seconds to 10 minutes with optional time variance
- **Global Hotkey**: Trigger pause sessions instantly from anywhere (default: Control-Command-0)
- **Session Tracking**: Monitor your meditation practice with completed session counts and total time spent

### Audio Experience
- **Ambient Sounds**: Seven calming background sounds (pad, pad2, keys, rain, walking, birds, waves)
- **Start/End Sounds**: Gentle audio cues to mark session boundaries
- **Volume Controls**: Independent volume adjustment for ambient and notification sounds
- **Silence Control**: Configure gaps between ambient sound loops

### Automatic Activation Modes
Pause supports three independent activation modes that can run simultaneously:

1. **Repeated Activation**: Trigger sessions at fixed intervals (every 5-240 minutes)
2. **Random Activation**: Sessions at random intervals within a configurable range (5-240 minutes)
3. **Scheduled Activation**: Set specific times throughout the day for automatic sessions

### Advanced Features
- **Time Variance**: Add randomness to session durations (±0-120 seconds)
- **Recalculate on Activation**: Optionally reset all timers when any session starts
- **Customizable Hotkey**: Record your own global keyboard shortcut
- **Undo/Redo**: Full history support for scheduled time management
- **Menu Bar Display**: Optional menu bar presence

## Requirements

- macOS 15.3 or later
- Xcode 16.4 (for development)
- Swift 5.0

## Installation

### For Users
1. Download the latest release from the [Releases](../../releases) page
2. Drag Pause.app to your Applications folder
3. Launch Pause and configure your preferences

### For Developers
```bash
# Clone the repository
git clone https://github.com/yourusername/Pause.git
cd Pause

# Open in Xcode
open Pause.xcodeproj

# Build and run
xcodebuild -project Pause.xcodeproj -scheme Pause -configuration Debug
```

## Usage

### Basic Usage
1. Launch Pause and configure your preferred session duration
2. Press Control-Command-0 (or your custom hotkey) to start a breathing session
3. Press SPACE during a session to exit early
4. Sessions that complete fully are tracked in your statistics

### Setting Up Automatic Activations
1. Navigate to the **Activation** tab in settings
2. Enable your preferred activation mode(s):
   - **Repeated**: Set a fixed interval (e.g., every 60 minutes)
   - **Random**: Define a range (e.g., between 30-120 minutes)
   - **Scheduled**: Add specific times (e.g., 9:00 AM, 2:00 PM, 5:00 PM)
3. The app will automatically trigger sessions according to your schedule

### Customizing Audio
1. Navigate to the **General** tab
2. Enable/disable ambient sounds, start sounds, and end sounds
3. Adjust volumes independently for each sound type
4. Configure silence duration between ambient sound loops

### Changing the Hotkey
1. Navigate to the **Shortcuts** tab
2. Click "Record New Hotkey"
3. Press your desired key combination (must include at least one modifier key)
4. The hotkey updates automatically

## Project Structure

```
Pause/
├── Pause/                  # Main application target
│   ├── PauseApp.swift     # App entry point
│   ├── ContentView.swift  # Main UI (settings + breathing view)
│   ├── AppState.swift     # Session state management
│   ├── Settings.swift     # User preferences & persistence
│   ├── ActivationScheduler.swift  # Timer orchestration
│   ├── GlobalHotkeyManager.swift  # Hotkey registration
│   └── Assets.xcassets/   # App icons and visual assets
├── PauseTests/            # Unit tests
├── PauseUITests/          # UI tests
└── README.md
```

## Architecture

Pause uses a singleton-based architecture with SwiftUI for the UI layer:

- **AppState.shared**: Controls pause mode state, timer logic, audio playback, and fullscreen window management
- **Settings.shared**: Manages user preferences backed by UserDefaults with `@Published` properties
- **ActivationScheduler.shared**: Handles three independent activation modes (repeated, random, scheduled)
- **GlobalHotkeyManager.shared**: Registers global hotkeys using Carbon APIs

All three activation modes can run simultaneously and independently.

## Building and Testing

### Build Commands
```bash
# Debug build
xcodebuild -project Pause.xcodeproj -scheme Pause -configuration Debug build

# Release build
xcodebuild -project Pause.xcodeproj -scheme Pause -configuration Release build

# Clean build artifacts
xcodebuild -project Pause.xcodeproj -scheme Pause clean
```

### Running Tests
```bash
# Run all tests
xcodebuild test -project Pause.xcodeproj -scheme Pause

# Run only unit tests
xcodebuild test -project Pause.xcodeproj -scheme Pause -only-testing:PauseTests

# Run only UI tests
xcodebuild test -project Pause.xcodeproj -scheme Pause -only-testing:PauseUITests
```

Note: This project uses Swift Testing framework (the modern Swift testing framework) rather than XCTest.

## Development

### Adding New Features
New `.swift` files added to the `Pause/` directory are automatically included in the build due to Xcode's modern file system synchronization.

### SwiftUI Previews
Views include `#Preview` macros for live previews in Xcode Canvas during development.

### Debugging
The app prints helpful debug messages to the console, including:
- Session start/completion events
- Audio playback status
- Timer activation events

## Entitlements

The app runs in a sandboxed environment with:
- App sandbox enabled
- Read-only access to user-selected files
- App Groups capability

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

[Add your license here]

## Acknowledgments

- Built with SwiftUI
- Uses AVFoundation for audio playback
- Carbon HIToolbox for global hotkey registration

## Support

If you encounter any issues or have suggestions, please [open an issue](../../issues) on GitHub.
