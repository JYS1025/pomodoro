# Pomodoro

A minimal macOS menu bar app for Pomodoro-style focus sessions.

## Overview

Pomodoro lives in your menu bar and stays out of the way. Click the icon to start a session, take your break when the alarm fires, and repeat. The current time and session type are visible at a glance without opening anything.

## Features

- Configurable study and break durations
- Alarm sound with adjustable volume (up to 4× amplification via AVAudioEngine)
- Session skip and manual reset
- Adapts to macOS light and dark mode

## Requirements

- macOS 14 Sonoma or later
- Xcode 15+ or Swift 5.9+ (Swift Package Manager)

## Running Locally

```bash
git clone <repo-url>
cd Pomodoro/Pomodoro
swift run Pomodoro
```

The app will appear in your menu bar immediately after launch.

## Project Structure

```
Pomodoro/
└── Sources/
    ├── PomodoroApp.swift       # App entry point, MenuBarExtra
    ├── TimerView.swift         # UI layer
    └── TimerViewModel.swift    # Timer logic, audio, notifications
```

## Notes

Running as a raw Swift Package executable means `UNUserNotificationCenter` requires a bundle identifier to work. Notifications are silently disabled in this mode — package the app as a proper `.app` bundle with a valid `Info.plist` to enable them.
