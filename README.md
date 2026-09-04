# Islemetry

**Live device telemetry for iPhone, surfaced through Live Activities and the Dynamic Island.**

Islemetry is a native SwiftUI iOS app focused on glanceable device information. It collects user-visible device metrics and presents a compact selection through ActivityKit on the Lock Screen and Dynamic Island.

## V0.1 scope

- Battery level and charging state
- Low Power Mode
- Thermal state
- Physical memory capacity
- Storage capacity and available space
- CPU core count
- Maximum display refresh rate
- Network path (Wi‑Fi / cellular / wired / offline)
- iPhone model identifier and iOS version
- Start, refresh, and stop a Live Activity
- Compact, minimal, expanded, and Lock Screen Live Activity layouts

## Architecture

```text
Islemetry/
├── App/
├── Models/
└── Services/
Shared/
└── DeviceActivityAttributes.swift
IslemetryWidgets/
├── IslemetryWidgetsBundle.swift
├── IslemetryLiveActivity.swift
└── Info.plist
```

## Apple frameworks

- SwiftUI
- ActivityKit
- WidgetKit
- Network
- UIKit
- Foundation

## Privacy

The V0.1 architecture keeps telemetry on-device. Before App Store distribution, every Required Reason API used by the final build will be declared in `PrivacyInfo.xcprivacy` with the matching Apple-approved reason.

## Roadmap

1. **V0.1** — Core device snapshot + Dynamic Island Live Activity
2. **V0.2** — Configurable metrics and profiles
3. **V0.3** — Shortcuts / App Intents
4. **V0.4** — Network diagnostics and richer telemetry
5. **V0.5** — Optional WeatherKit / HealthKit modules
6. **V1.0** — Polished App Store-ready release

## Project status

Early development. The first milestone intentionally uses public Apple frameworks and no third-party dependencies.
