# Islemetry

[Español](README.es.md) · **English**

**Live iPhone device telemetry through Live Activities and the Dynamic Island.**

Islemetry is a native SwiftUI iOS application that turns the Dynamic Island into a configurable, glanceable device-status monitor. Choose the information that matters to you, keep two metrics visible in the compact Island, and press and hold to reveal a richer expanded telemetry snapshot.

> **Development status:** V0.2 in active development. V0.1 has already been built, installed, and validated on a physical iPhone.

## What Islemetry does

Islemetry collects device information exposed through public Apple frameworks and sends a configurable telemetry snapshot to an ActivityKit Live Activity.

You can choose:

- **Compact Leading** metric
- **Compact Trailing** metric
- Up to **six expanded metrics**
- A custom **Dynamic Island text color**
- **System / English / Español** language behavior

The same Live Activity also appears on the Lock Screen, and the app includes a Home-screen preview that mirrors the saved Dynamic Island configuration and selected text color.

## Current features

- Start, refresh, and stop a Live Activity
- Compact, minimal, expanded, and Lock Screen presentations
- User-selectable compact Leading and Trailing metrics
- Up to six configurable expanded metrics
- Full iOS Color Picker for Dynamic Island telemetry text and symbols
- Persistent HEX color storage with white (`#FFFFFF`) as the default
- Persistent on-device Dynamic Island configuration
- Home-screen preview of the exact saved Island layout and color
- **System / English / Español** language selector
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
git switch bootstrap/v0.1
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

A distributable `.ipa` must be produced from a successful signed Xcode Archive. The repository intentionally does not contain private signing certificates, provisioning profiles, credentials, or a universal pre-signed IPA.

See **[IPA Guide](docs/IPA.md)** for:

- Xcode Organizer export
- `xcodebuild` archive/export commands
- signing considerations
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

Many metrics are **snapshots**. Islemetry refreshes them when the app receives execution time and then updates the ActivityKit state. Time-based or system-managed Live Activity presentation can continue while the main application process is suspended, but arbitrary CPU/RAM-style telemetry cannot be sampled continuously by a normal suspended app.

## Privacy and App Store orientation

Islemetry is designed to keep device telemetry on-device whenever possible and uses public Apple frameworks.

Current Required Reason API decisions include:

- Disk-space information is displayed to the user under Apple's approved reason `85F4.1`.
- UserDefaults stores Islemetry's own metric-layout, language, and Dynamic Island color preferences under approved reason `CA92.1`.
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
2. **V0.2** — Configurable Dynamic Island + expanded telemetry + preview + language and appearance controls 🚧 current
3. **V0.3** — Profiles + Shortcuts / App Intents
4. **V0.4** — Network diagnostics and richer telemetry
5. **V0.5** — Optional WeatherKit / HealthKit modules
6. **V1.0** — Polished App Store-ready release

## Logo

The selected Islemetry identity combines the letter **I** with a blue telemetry waveform on a dark rounded-square icon. The final App Icon asset will use the symbol-only version so it remains recognizable at iOS icon sizes.

## Repository

```text
https://github.com/tiburonns/Islemetry
```

Islemetry is currently an actively developed project and intentionally favors public APIs, transparent telemetry behavior, and native iOS technologies over private system-monitoring APIs.
