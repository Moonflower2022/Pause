# CLAUDE.md

AI assistant guidance for Pause macOS meditation app.

---

## Quick Reference

**Build**: `xcodebuild -project Pause.xcodeproj -scheme Pause -configuration Debug build`
**Test**: Uses **Swift Testing** (NOT XCTest) - `@Test` + `#expect()`, never `XCTestCase`

---

## Architecture

### Five Core Singletons
1. **AppState** - Session state, AVAudioPlayer, fullscreen windows, stats
2. **Settings** - `@Published` properties with `didSet` → auto-save to UserDefaults
3. **ActivationScheduler** - 3 independent timers (repeated/random/scheduled)
4. **GlobalHotkeyManager** - Carbon HIToolbox for global hotkeys
5. **MenuBarManager** - Optional NSStatusBar

### Refactored Structure (2024)
```
Pause/
├── Views/
│   ├── BreathingView.swift
│   ├── Components/[NextActivationCountdown, TabButton]
│   └── Settings/[5 tab files]
└── Utilities/SliderHelpers.swift
```

---

## Critical Implementation Details

### Carbon Hotkey System
```swift
// Modern Cocoa has NO global hotkey API - must use legacy Carbon
RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)

// C callback with unmanaged self pointer
func eventHandler(..., userData: UnsafeMutableRawPointer?) -> OSStatus {
    let manager = Unmanaged<GlobalHotkeyManager>.fromOpaque(userData).takeUnretainedValue()
    manager.onHotkeyPressed()
    return noErr
}
```
**CRITICAL**: Must `UnregisterEventHotKey()` in `deinit` or system leaks

### Timer Orchestration
- **Repeated**: `Timer.scheduledTimer(interval, repeats: true)`
- **Random**: Non-repeating, reschedules self with new random interval after firing
- **Scheduled**: Up to 15 daily timers, each auto-reschedules for next day

### Settings Persistence
```swift
@Published var pauseDuration: Int {
    didSet { UserDefaults.standard.set(pauseDuration, forKey: "pauseDuration") }
}
```
No explicit save calls - reactive auto-persistence via `didSet`

### Fullscreen Management
```swift
// MUST delay 0.3s or window not ready
DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    window.toggleFullScreen(nil)
}
```
Strong refs in `AppState.createdWindows: [NSWindow]` prevent dealloc

### Audio System
- Random selection (1 of 7) per session
- Two modes: `numberOfLoops = -1` (loop) or `soundRepeatTimer` (gaps)
- Delegate: `AVAudioPlayerDelegate` → `audioPlayerDidFinishPlaying`
- Cleanup: **Always** `stop()` + `nil` out players

---

## Common Gotchas

1. **Timer Retention**: Use `[weak self]` in timer closures
2. **Space Exit**: `NSEvent.addLocalMonitorForEvents` (NOT global) for fullscreen
3. **Hotkey Cleanup**: `UnregisterEventHotKey()` in `deinit` mandatory
4. **Testing**: Swift Testing only - importing `XCTest` is wrong framework
5. **Fullscreen**: 0.3s delay before `toggleFullScreen(nil)` required

---

*See README.md for user docs. This is developer/AI reference only.*
