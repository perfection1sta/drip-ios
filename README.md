# Drip 💧

A feature-rich **Workout of the Day** iOS app built with SwiftUI, SwiftData, and Swift Charts.

---

## Features

| Feature | Details |
|---|---|
| **Daily WOD** | Auto-generated workout based on day-of-week split + user fitness level |
| **Active Workout** | Set/rep tracker with weight input, animated rest timer, PR detection |
| **Rest Timer** | Animated circular countdown with haptic pulses and skip/adjust controls |
| **Progress Charts** | Weekly volume bar chart (Swift Charts), streak calendar, personal records |
| **Exercise Library** | 25 exercises with search, filter by muscle/category/difficulty |
| **Daily Notifications** | Configurable reminder time + 9 PM streak-loss warning |
| **Spring Animations** | matchedGeometryEffect hero transitions, particle burst celebrations, stagger entrances |
| **Haptic Feedback** | Every interaction has physical feedback via `HapticManager` |
| **Reduce Motion** | All decorative animations respect `accessibilityReduceMotion` |
| **Dark Mode** | Dark-first design with adaptive light mode support |

---

## Tech Stack

- **Language:** Swift 5.10
- **UI:** SwiftUI (MVVM, `@Observable` macro)
- **Persistence:** SwiftData
- **Charts:** Swift Charts framework
- **Notifications:** UserNotifications framework
- **Project:** XcodeGen

---

## Getting Started

### Prerequisites
- macOS 14+ with Xcode 15+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Setup

```bash
git clone https://github.com/akshaykailat/drip-ios.git
cd drip-ios
xcodegen generate
open Drip.xcodeproj
```

Select **iPhone 15 Simulator** and press `⌘R`.

---

## Architecture

```
Drip/
├── App/               — Entry point (DripApp.swift)
├── DesignSystem/      — Design tokens + base components
├── Models/            — SwiftData @Model entities
├── ViewModels/        — @Observable state management
├── Views/             — Screen & component views
├── Services/          — WorkoutGenerator, Notifications, SwiftData seeding
└── Utilities/         — Extensions (Date, View, Color)
```

See [`DESIGN_GUIDELINES.md`](./DESIGN_GUIDELINES.md) for the full design system documentation.

---

## Design System

Drip uses a token-based design system with:
- **7 brand colours** + full semantic surface/text/feedback palette
- **4 spring animation presets** (snappy / bouncy / smooth / gentle)
- **4pt grid spacing** system
- **16 typography tokens** (SF Pro Display, all monospaced numeric styles)

---

## License

MIT
