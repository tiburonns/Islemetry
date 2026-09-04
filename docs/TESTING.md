# Islemetry V0.1 — On-Device Test Plan

[Español](TESTING.es.md) · **English**

This checklist is for the first installation of Islemetry on a physical iPhone with Dynamic Island.

## Goal

Validate that the app builds, signs, launches, collects the initial telemetry snapshot, and successfully creates, updates, and stops the Live Activity on both the Lock Screen and Dynamic Island.

## Test environment

Record the following before testing:

- Date and time
- Mac model
- macOS version
- Xcode version
- iPhone model
- iOS version
- Apple Developer signing team used
- Git commit / branch tested

## Build and installation

1. Open `Islemetry.xcodeproj` in Xcode.
2. Select the `Islemetry` target.
3. Under **Signing & Capabilities**, select your Apple Developer team.
4. Confirm that the main app and `IslemetryWidgets` extension have valid, unique bundle identifiers.
5. Select the physical iPhone as the run destination.
6. Build and run the app.

### Expected result

- Xcode completes the build without errors.
- Islemetry installs on the iPhone.
- Islemetry opens without crashing.

## Main app test

1. Launch Islemetry.
2. Review the telemetry displayed in the app.
3. Confirm that the following values appear when supported:
   - Battery level
   - Charging state
   - Low Power Mode
   - Thermal state
   - Physical memory
   - Storage
   - CPU core count
   - Maximum display refresh rate
   - Network path
   - Device identifier
   - iOS version

### Record

For any incorrect or missing value, capture:

- Metric name
- Value shown
- Value expected, if known
- Screenshot
- Whether reopening the app changes the result

## Live Activity start test

1. In Islemetry, start the Live Activity.
2. Return to the Home Screen.
3. Lock the iPhone.
4. Unlock the iPhone.
5. Observe the Dynamic Island.

### Expected result

- A Live Activity starts successfully.
- The Lock Screen presentation is visible.
- The compact Dynamic Island presentation is visible.
- Pressing and holding the Dynamic Island displays the expanded presentation.
- No duplicated Live Activities are unintentionally created.

## Live Activity refresh test

1. Note the currently displayed telemetry.
2. Change a value that can reasonably change, such as battery state, charging state, network path, or Low Power Mode.
3. Return to Islemetry and press **Refresh**.
4. Check the Live Activity again.

### Expected result

- The Live Activity remains active.
- Updated values are reflected after refresh.
- The Live Activity does not disappear or duplicate itself.

## Live Activity stop test

1. Press **Stop** in Islemetry.
2. Check the Dynamic Island.
3. Check the Lock Screen.

### Expected result

- The Live Activity ends cleanly.
- Islemetry disappears from the Dynamic Island.
- Islemetry disappears from the Lock Screen after the system completes the dismissal.

## Rotation and presentation test

Check the app and Live Activity in common states:

- iPhone unlocked
- iPhone locked
- Always-On Display, if supported
- Low Power Mode on/off
- Wi-Fi connected
- Cellular connection
- Airplane Mode / offline
- Charging / disconnected from charger

## Failure report template

Use this format when reporting a problem:

```text
Test:
Device:
iOS:
Xcode:
Branch / commit:

Expected:

Actual:

Steps to reproduce:
1.
2.
3.

Xcode error or console output:

Screenshot / screen recording:
```

## V0.1 acceptance criteria

V0.1 hardware validation is considered successful when:

- The project builds on a physical iPhone.
- The app launches reliably.
- Core telemetry is visible.
- A Live Activity can be started.
- Compact, expanded, and Lock Screen presentations render.
- The Live Activity can be refreshed.
- The Live Activity can be stopped without leaving an unintended active session.

Any build, signing, ActivityKit, layout, or metric issue found during this test should be documented before the bootstrap PR is merged.
