# Dynamic Island Configuration

[Español](CONFIGURATION.es.md) · **English**

Islemetry lets you decide which device metrics are shown in the Dynamic Island and customize the color used for its telemetry text and symbols. The configuration is stored locally on the iPhone and reused the next time a Live Activity starts.

## Change what the Dynamic Island shows

1. Open **Islemetry**.
2. Tap the **Configure Dynamic Island** card.
3. Under **Compact Dynamic Island**, choose:
   - **Leading** — the metric shown on the left side.
   - **Trailing** — the metric shown on the right side.
4. Under **Expanded Dynamic Island**, choose up to six additional metrics.
5. Select **None** for expanded slots you do not want to use.
6. Under **Appearance**, choose the text color with the system Color Picker.
7. Tap **Apply to Live Activity**.

If a Live Activity is already running, **Apply to Live Activity** refreshes it with the new layout and color. If no activity is running, the choices are saved and used the next time you press **Start**.

## Compact vs expanded layout

The compact and expanded layouts are intentionally independent:

- **Compact Leading / Trailing** are only used while the Dynamic Island is collapsed.
- The expanded presentation uses the six **Expanded Dynamic Island** slots directly.
- Expanded slots 1 and 2 are rendered in the upper leading/trailing regions.
- Expanded slots 3–6 are rendered in a compact 2×2 grid below them.
- The compact Leading/Trailing values are not repeated in the expanded view.

This keeps the expanded view to a maximum of six telemetry metrics and prevents the bottom rows from being clipped by the Dynamic Island's available height.

## Dynamic Island text color

The **Live Activity Appearance** section contains a full iOS Color Picker rather than a fixed palette.

- Default color: white (`#FFFFFF`).
- Opacity is intentionally disabled for predictable legibility against the Dynamic Island's black background.
- The selected color is persisted locally as an RGB HEX value.
- The current HEX value is shown in the configuration screen.
- **Reset to white** restores the default.
- The main-screen Dynamic Island preview uses the same selected color.
- When applied, the color is included in the ActivityKit content state so a running Live Activity can change color without being restarted.

The selected color is used for telemetry values and metric symbols in the compact, expanded, minimal, and Lock Screen Live Activity presentations. Secondary labels use a reduced-opacity version of the same color to preserve hierarchy.

Very dark colors can have poor contrast against the Dynamic Island's black background, so brighter colors are recommended.

## Language

Islemetry offers three language choices:

- **System / Sistema** — follows the current iOS language.
- **English** — always uses English.
- **Español** — always uses Spanish.

When **System / Sistema** is selected, Spanish iOS locales (`es-*`) use Spanish and other currently unsupported system languages fall back to English. The preference is stored locally. A running Live Activity receives the resolved `en` or `es` language when Islemetry refreshes it.

## App appearance

The Appearance card controls the app interface independently from the telemetry color:

- **System** follows the current iOS appearance.
- **Light** keeps Islemetry in light mode.
- **Dark** keeps Islemetry in dark mode.

The selection is applied immediately and stored locally. SwiftUI semantic colors and materials adapt automatically so the dashboard, forms, controls, and metric cards retain contrast. The Dynamic Island preview intentionally stays black because it represents the system surface.

## Default layout

### Compact

- Leading: Battery
- Trailing: Thermal State
- Text color: White (`#FFFFFF`)

### Expanded

1. Network
2. Storage Free
3. Memory Total
4. Active CPU Cores
5. Max Refresh Rate
6. Low Power Mode

## Available metrics

### Power and thermal

- Battery percentage
- Charging state
- Low Power Mode
- Thermal state
- Screen brightness

### CPU and memory

- CPU core count
- Active CPU core count
- Physical memory total

> `Memory Total` is the physical memory reported by `ProcessInfo`. It is not a continuously updated global RAM-used percentage for the entire device.

### Storage

- Storage summary
- Storage free
- Storage used
- Storage total

Storage is calculated from the volume capacity values exposed by Foundation.

### Display

- Maximum refresh rate
- ProMotion capability/status inferred from maximum refresh rate
- Native display resolution
- Native display scale
- Brightness

> `Max Refresh Rate` is the maximum refresh rate exposed for the screen. It is not a real-time measurement of the refresh rate used by another app.

### Network

- Current interface: Wi-Fi, cellular, Ethernet, connected, or offline
- Low Data Mode / constrained path
- Expensive network path
- IPv4 support
- IPv6 support
- DNS support

> `Expensive Network` is Apple's `NWPath.isExpensive` system classification. It does not represent the actual monetary cost of the connection.

### Device and system

- Hardware identifier
- Device model
- iOS / system version
- Locale
- Time zone

## Update behavior

The Live Activity displays the latest telemetry snapshot sent by Islemetry. While the app is active, Islemetry automatically captures a snapshot and requests a Live Activity update every three seconds. iOS controls the final Live Activity rendering cadence and does not allow Islemetry to keep this loop running after the app is suspended in the background.

The **Refresh** button remains available for an immediate snapshot. Layout and color changes can also be pushed with **Apply to Live Activity**.

## Privacy and App Store compatibility

Islemetry intentionally uses public Apple frameworks. Disk-space information is a Required Reason API use case; Apple's approved reason `85F4.1` permits displaying disk-space information to the user. UserDefaults is used only to save Islemetry's own configuration, including metric selection, language, and text color, corresponding to approved reason `CA92.1`.

System uptime is intentionally not exposed as a metric in this App Store-oriented build because Apple's approved reasons for the system-boot-time API do not include simply displaying device uptime as a system-monitor statistic.


## Location and local weather metrics

Four location-aware metrics are available in the normal Dynamic Island picker:

- **Local Temperature** — current outdoor temperature for the latest iPhone location.
- **Feels Like** — apparent temperature.
- **Weather** — current weather condition.
- **Location** — rounded coordinates from the latest location snapshot.

They can be assigned to Compact Leading, Compact Trailing, or any expanded slot.

### Background location

The Home-screen **Location & Weather** card includes **Background location**. When disabled, Islemetry uses one-shot location requests while the app is active. When enabled, Islemetry requests the permission needed for background location and starts Core Location updates with kilometer-level accuracy and a 2 km distance filter to reduce battery use.

Location events can trigger a weather refresh and an ActivityKit update. This does **not** make Islemetry an always-running process; iOS controls background delivery.

### Refresh policy

Automatic weather requests are throttled. Islemetry skips another weather request when the previous successful result is less than 15 minutes old and the device has moved less than 5 km. **Refresh Weather** forces a new request.

### Weather provider

Current weather is provided by **Open-Meteo** and Islemetry shows a visible attribution link next to the weather card.


## All-metric background refresh

General background telemetry is always scheduled by Islemetry; it is separate from the optional Background Location switch.

- Foreground: full snapshot approximately every 3 seconds while the app is active.
- Background app refresh: full snapshot whenever iOS executes `com.tiburonns.islemetry.refresh`.
- Background location: every delivered location event is also treated as a full-snapshot refresh opportunity before local weather is refreshed.

The Live Activity receives the same currently selected metrics after each successful background opportunity. iOS does not guarantee a 15-minute cadence: `earliestBeginDate` only prevents execution before that time.
