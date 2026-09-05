# Islemetry

[Español](README.es.md) · **English**

**Live device telemetry for iPhone, surfaced through Live Activities and the Dynamic Island.**

Islemetry is a native SwiftUI iOS app focused on glanceable device information. It collects user-visible device metrics and presents a configurable selection through ActivityKit on the Lock Screen and Dynamic Island.

## Current features

- Start, refresh, and stop a Live Activity
- Compact, minimal, expanded, and Lock Screen Live Activity layouts
- User-selectable compact **Leading** and **Trailing** metrics
- Up to six user-selectable expanded metrics
- Persistent Dynamic Island configuration stored locally on-device
- Main-screen preview of the exact compact and expanded metrics selected for the Dynamic Island
- In-app **English / Español** language selector
- Metric names, status values, configuration UI, and Live Activity chrome update to the selected language
- Language changes refresh an active Live Activity automatically
- 27 available device/system metrics
- No third-party runtime dependencies

### Metric categories

- **Power:** battery, charging state, Low Power Mode, thermal state, brightness
- **CPU / memory:** CPU cores, active CPU cores, physical memory total
- **Storage:** summary, free, used, total
- **Display:** maximum refresh rate, ProMotion indication, native resolution, native scale
- **Network:** interface, Low Data Mode, expensive-path state, IPv4, IPv6, DNS
- **Device / system:** hardware identifier, device model, iOS version, locale, time zone

See [docs/CONFIGURATION.md](docs/CONFIGURATION.md) for the complete Dynamic Island configuration guide, preview behavior, language selection, and metric notes.

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
```

## Apple frameworks

- SwiftUI
- ActivityKit
- WidgetKit
- Network
- UIKit
- Foundation

## Privacy

Islemetry is designed to keep device telemetry on-device. Disk-space information is used to display storage information to the user, matching Apple's Required Reason API reason `85F4.1`. UserDefaults stores Islemetry's own display and language preferences, matching reason `CA92.1`.

System uptime is intentionally excluded from the App Store-oriented metric catalog because Apple's approved reasons for the system-boot-time API do not include displaying uptime as a general device-monitor statistic.

## Documentation policy

All important project documentation is maintained in both English and Spanish. English files use the default name and Spanish translations use the `.es.md` suffix.

Examples:

- `README.md` / `README.es.md`
- `docs/TESTING.md` / `docs/TESTING.es.md`
- `docs/CONFIGURATION.md` / `docs/CONFIGURATION.es.md`

When behavior, architecture, testing procedures, privacy requirements, or roadmap decisions change, both language versions should be updated together.

## On-device testing

The current V0.2 hardware validation procedure is documented in [docs/TESTING.md](docs/TESTING.md).

V0.1 has been successfully built, installed, and validated on a real iPhone. The current branch extends that working baseline with configurable Dynamic Island content, expanded telemetry, a main-screen Island preview, and in-app English/Spanish switching.

## Roadmap

1. **V0.1** — Core device snapshot + Dynamic Island Live Activity ✅ hardware validated
2. **V0.2** — Configurable Dynamic Island metrics + expanded telemetry + bilingual UI 🚧 current
3. **V0.3** — Profiles + Shortcuts / App Intents
4. **V0.4** — Network diagnostics and richer telemetry
5. **V0.5** — Optional WeatherKit / HealthKit modules
6. **V1.0** — Polished App Store-ready release

## Project status

Active development. Islemetry intentionally uses public Apple frameworks and no third-party runtime dependencies.
