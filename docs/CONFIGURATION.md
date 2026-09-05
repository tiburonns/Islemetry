# Dynamic Island Configuration

[Español](CONFIGURATION.es.md) · **English**

Islemetry lets you decide which device metrics are shown in the Dynamic Island. The configuration is stored locally on the iPhone and reused the next time a Live Activity starts.

## Change what the Dynamic Island shows

1. Open **Islemetry**.
2. Tap the **Dynamic Island** configuration card.
3. Under **Compact Dynamic Island**, choose:
   - **Leading** — the metric shown on the left side.
   - **Trailing** — the metric shown on the right side.
4. Under **Expanded Dynamic Island**, choose up to six additional metrics.
5. Select **None** for expanded slots you do not want to use.
6. Tap **Apply to Live Activity**.

If a Live Activity is already running, **Apply to Live Activity** refreshes it with the new layout. If no activity is running, the choices are saved and used the next time you press **Start**.

## Default layout

### Compact

- Leading: Battery
- Trailing: Thermal State

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

The Live Activity displays the latest telemetry snapshot sent by Islemetry. iOS does not allow Islemetry to run continuously in the background like a desktop system monitor, so many metrics are refreshed when the app is active and Islemetry sends a new ActivityKit state.

The **Refresh** button captures a new snapshot and updates the active Live Activity.

## Privacy and App Store compatibility

Islemetry intentionally uses public Apple frameworks. Disk-space information is a Required Reason API use case; Apple's approved reason `85F4.1` permits displaying disk-space information to the user. UserDefaults is used only to save Islemetry's own configuration, corresponding to approved reason `CA92.1`.

System uptime is intentionally not exposed as a metric in this App Store-oriented build because Apple's approved reasons for the system-boot-time API do not include simply displaying device uptime as a system-monitor statistic.
