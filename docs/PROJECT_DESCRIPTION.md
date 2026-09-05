# Islemetry Project Description

[Español](PROJECT_DESCRIPTION.es.md) · **English**

## One-line description

**Live iPhone device telemetry displayed through Live Activities and the Dynamic Island.**

## Short GitHub description

Islemetry is a native SwiftUI iOS app that exposes configurable device telemetry through ActivityKit, the Lock Screen, and the Dynamic Island.

## Short product description

Islemetry turns the Dynamic Island into a compact device-status monitor. Choose the metrics that matter to you, keep them visible through a Live Activity, and expand the Island whenever you want a richer snapshot of your iPhone.

## Full project description

Islemetry is an iOS device-telemetry application designed around Live Activities and the Dynamic Island.

Instead of hiding device information inside a conventional dashboard, Islemetry lets the user choose which metrics should remain visible at a glance. Two metrics can be assigned to the compact Dynamic Island, while up to six additional metrics can be selected for the expanded presentation. The same Live Activity is also rendered on the Lock Screen.

The application currently exposes information across power, thermal state, CPU, memory, storage, display, network, and system categories. Examples include battery percentage, charging state, Low Power Mode, thermal state, physical memory, free/used/total storage, CPU core counts, maximum display refresh rate, ProMotion indication, brightness, current network interface, Low Data Mode, IPv4/IPv6/DNS support, device identifier, iOS version, locale, and time zone.

Islemetry includes a main-screen preview of the exact compact and expanded Dynamic Island configuration, persistent on-device preferences, and an in-app language selector with System, English, and Spanish modes. When the Live Activity is already running, layout and language changes can be pushed to the existing activity without intentionally creating a duplicate session.

The project is built natively with SwiftUI, ActivityKit, WidgetKit, Network, UIKit, and Foundation. It intentionally avoids third-party runtime dependencies and is being developed with App Store compatibility and privacy requirements in mind.

Because iOS does not allow an ordinary application to run continuously in the background like a desktop system monitor, Islemetry treats many values as telemetry snapshots. The app refreshes those values when it receives execution time and sends updated ActivityKit state to the Live Activity.

## Core principles

- **Glanceable:** important metrics should be visible without opening a full dashboard.
- **Configurable:** the user decides what the compact and expanded Dynamic Island show.
- **Native:** use public Apple frameworks and platform-native UI.
- **Private:** keep device telemetry local whenever possible.
- **Transparent:** distinguish true device values from inferred capabilities and snapshots.
- **App Store-oriented:** avoid unsupported private APIs and document Required Reason API usage.

## Current feature summary

- Live Activity start, refresh, and stop lifecycle
- Dynamic Island compact Leading / Trailing metric selection
- Up to six expanded metrics
- Lock Screen Live Activity
- Main-screen Dynamic Island preview
- Persistent on-device configuration
- System / English / Español language modes
- 27 device/system metrics
- No third-party runtime dependencies

## Suggested repository topics

```text
ios
swift
swiftui
activitykit
widgetkit
live-activities
dynamic-island
iphone
telemetry
system-monitor
```

## Suggested GitHub About text

```text
Live iPhone device telemetry through Live Activities and the Dynamic Island.
```

## Suggested release subtitle

```text
Configurable device telemetry for the Dynamic Island.
```

## Future-facing description

The architecture is intended to grow beyond the current V0.2 feature set with profiles, Shortcuts/App Intents, richer diagnostics, optional WeatherKit and HealthKit modules, and improved release/distribution workflows.
