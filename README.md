# Islemetry

[Español](README.es.md) · **English**

**Live iPhone device telemetry through Live Activities and the Dynamic Island.**

Islemetry is a native SwiftUI iOS application that turns the Dynamic Island into a configurable, glanceable device-status monitor. Choose the information that matters to you, keep two metrics visible in the compact Island, and press and hold to reveal a richer expanded telemetry snapshot.

> **Current release:** V0.2.1. It keeps the three-second foreground refresh while avoiding redundant Live Activity publications when visible values have not changed. Direct Xcode installation and the unsigned AltStore Classic package remain supported.

## What Islemetry does

Islemetry collects device information exposed through public Apple frameworks and sends a configurable telemetry snapshot to an ActivityKit Live Activity.

You can choose:

- **Compact Leading** metric
- **Compact Trailing** metric
- Up to **six expanded metrics**
- A custom **Dynamic Island telemetry color**
- **System / English / Español** language behavior
- **System / Light / Dark** app appearance

The same Live Activity also appears on the Lock Screen, and the app includes a Home-screen preview that mirrors the saved Dynamic Island configuration and selected telemetry color.

## Current features

- Start, refresh, and stop a Live Activity
- Compact, minimal, expanded, and Lock Screen presentations
- User-selectable compact Leading and Trailing metrics
- Up to six configurable expanded metrics
- Full iOS Color Picker for Dynamic Island telemetry text and metric symbols
- Persistent RGB HEX color storage with white (`#FFFFFF`) as the default
- Persistent on-device Dynamic Island configuration
- Home-screen preview of the exact saved Island layout and color
- **System / English / Español** language selector
- Persistent **System / Light / Dark** appearance selector
- Metric names, states, configuration UI, and Live Activity auxiliary text follow the effective language
- Language/layout/color changes can update an already-running Live Activity
- 27 current device/system metrics
- No third-party runtime dependencies

### Metric categories

- **Power:** battery, charging state, Low Power Mode, thermal state, brightness
- **CPU / memory:** CPU cores, active CPU cores, physical memory total
- **Storage:** summary, free, used, total
- **Display:** maximum refresh rate, ProMotion indication, native resolution, native scale
- **Network:** current interface, Low Data Mode, expensive-path state, IPv4, IPv6, DNS
- **Device / system:** hardware identifier, device model, iOS version, locale, time zone

## Quick start

Clone the repository:

```bash
git clone https://github.com/tiburonns/Islemetry.git
cd Islemetry
git switch main
open Islemetry.xcodeproj
```

Then in Xcode:

1. Select your Apple Developer team for `Islemetry`.
2. Select the same team for `IslemetryWidgets`.
3. Connect a physical iPhone.
4. Select it as the run destination.
5. Press `⌘R`.

For the complete setup guide, see **[Getting Started](docs/GETTING_STARTED.md)**.

## IPA

You do **not** need an IPA when installing Islemetry directly from Xcode.

The release IPA is an unsigned physical-device build intended for AltStore Classic to re-sign with the user's account. The repository intentionally does not contain private signing certificates, provisioning profiles, or Apple account credentials.

Add the stable source in **AltStore Classic → Browse → Sources → +**:

```text
https://raw.githubusercontent.com/tiburonns/Islemetry/main/altstore/source.json
```

See **[IPA Guide](docs/IPA.md)** for:

- Xcode Organizer export
- `xcodebuild` archive/export commands
- signing considerations
- unsigned AltStore build and validation scripts
- installation options
- GitHub Release checklist

## Project description

A reusable short/long project description, GitHub About text, suggested topics, and product copy are available in **[Project Description](docs/PROJECT_DESCRIPTION.md)**.

Short description:

> Islemetry is a native SwiftUI iOS app that exposes configurable device telemetry through ActivityKit, the Lock Screen, and the Dynamic Island.

## Architecture

```text
Islemetry/
├── App/
├── Models/
├── Resources/
├── Services/
├── Info.plist
└── PrivacyInfo.xcprivacy

Shared/
└── DeviceActivityAttributes.swift

IslemetryWidgets/
├── IslemetryWidgetsBundle.swift
├── IslemetryLiveActivity.swift
└── Info.plist

docs/
├── GETTING_STARTED.md / GETTING_STARTED.es.md
├── IPA.md / IPA.es.md
├── PROJECT_DESCRIPTION.md / PROJECT_DESCRIPTION.es.md
├── CONFIGURATION.md / CONFIGURATION.es.md
└── TESTING.md / TESTING.es.md

altstore/
└── source.json

script/
├── build_altstore_ipa.sh
├── update_altstore_source.py
└── validate_altstore.py
```

## Apple frameworks

- SwiftUI
- ActivityKit
- WidgetKit
- Network
- UIKit
- Foundation

## Background-update model

Islemetry is intentionally not designed to pretend that iOS provides desktop-style continuous system monitoring in the background.

Many metrics are **snapshots**. While Islemetry is active, it automatically captures a new snapshot every three seconds and updates any running Live Activity. System notifications for battery, power, thermal state, brightness, and network changes can also trigger immediate refreshes. Time-based or system-managed Live Activity presentation can continue while the main application process is suspended, but iOS pauses Islemetry's three-second refresh loop in the background and arbitrary CPU/RAM-style telemetry cannot be sampled continuously by a normal suspended app.

## Privacy and App Store orientation

Islemetry is designed to keep device telemetry on-device whenever possible and uses public Apple frameworks.

Current Required Reason API decisions include:

- Disk-space information is displayed to the user under Apple's approved reason `85F4.1`.
- UserDefaults stores Islemetry's own metric-layout, language, appearance, and Dynamic Island color preferences under approved reason `CA92.1`.
- General device uptime is intentionally excluded because the approved reasons for the relevant system-boot-time API do not include using it as a generic system-monitor statistic.

No signing credentials or private Apple account material should ever be committed to this repository.

## Documentation

All important Islemetry documentation is maintained in **English and Spanish**. English uses the default filename and Spanish uses `.es.md`.

- [Getting Started](docs/GETTING_STARTED.md) · [Comenzar](docs/GETTING_STARTED.es.md)
- [IPA Guide](docs/IPA.md) · [Guía IPA](docs/IPA.es.md)
- [Project Description](docs/PROJECT_DESCRIPTION.md) · [Descripción del proyecto](docs/PROJECT_DESCRIPTION.es.md)
- [Dynamic Island Configuration](docs/CONFIGURATION.md) · [Configuración](docs/CONFIGURATION.es.md)
- [Testing](docs/TESTING.md) · [Pruebas](docs/TESTING.es.md)

When functionality, architecture, installation, privacy, or release behavior changes, both language versions should be updated together.

## Roadmap

1. **V0.1** — Core device snapshot + Dynamic Island Live Activity ✅ hardware validated
2. **V0.2** — Configurable Dynamic Island + expanded telemetry + preview + language and appearance controls ✅ released
3. **V0.3** — Profiles + Shortcuts / App Intents
4. **V0.4** — Network diagnostics and richer telemetry
5. **V0.5** — Optional WeatherKit / HealthKit modules
6. **V1.0** — Polished App Store-ready release

## Logo

The Islemetry icon combines a luminous cyan-to-violet telemetry pulse with a Dynamic Island-inspired capsule on a deep navy background.

## Repository

```text
https://github.com/tiburonns/Islemetry
```

Islemetry is currently an actively developed project and intentionally favors public APIs, transparent telemetry behavior, and native iOS technologies over private system-monitoring APIs.
