# Islemetry V0.2 — On-Device Test Plan

[Español](TESTING.es.md) · **English**

This checklist validates the current Islemetry build on a physical iPhone with Dynamic Island. V0.1 has already been successfully built and installed on real hardware; V0.2 adds configurable Island content, expanded telemetry, a Home-screen Island preview, language and appearance controls, and custom Dynamic Island text color.

## Goal

Validate that Islemetry builds, launches, collects telemetry, previews the saved Dynamic Island layout and color correctly, changes language and appearance without restarting, and successfully creates, updates, and stops the Live Activity on both the Lock Screen and Dynamic Island.

## Test environment

Record:

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

## Main app telemetry test

1. Launch Islemetry.
2. Review all metric cards.
3. Confirm that the 31 current metrics render without missing SF Symbols, blank values, or severe clipping.
4. Compare values that can be verified easily: battery, charging, Low Power Mode, storage, refresh rate, brightness, network, iOS version, locale, and time zone.

## Dynamic Island preview test

1. On the Home screen, find **Dynamic Island Preview**.
2. Confirm that the compact preview shows the currently selected Leading and Trailing metrics and their current values.
3. Confirm that the expanded preview shows the selected expanded metrics.
4. Open **Configure Dynamic Island** and change Leading, Trailing, and at least three expanded slots.
5. Set at least one expanded slot to **None**.
6. Return to Home.

### Expected result

- The Home preview matches the saved configuration.
- A slot set to None is not shown in the expanded preview.
- The preview uses the latest telemetry values.
- Duplicate expanded selections do not render duplicate cards.

## Dynamic Island color test

1. Open **Configure Dynamic Island**.
2. Under **Appearance**, open **Text color**.
3. Choose a clearly visible color such as cyan, green, yellow, or magenta.
4. Confirm that the displayed HEX value changes.
5. Return to Home and verify the compact and expanded previews use the selected color.
6. Reopen the configuration and tap **Reset to white**.
7. Confirm the HEX value returns to `#FFFFFF`.

### Expected result

- The full iOS Color Picker opens correctly.
- The selected color is persisted as a HEX value.
- The Home preview reflects the selected color.
- Reset restores white.
- Force-quitting and reopening Islemetry preserves the last saved color.

## Language test

1. Test **System / Sistema**, **English**, and **Español**.
2. Review the status card, buttons, language card, Dynamic Island preview, configuration card, metric names, and localized metric values.
3. In System mode, confirm Spanish iOS uses Spanish and unsupported languages currently fall back to English.
4. Force-quit Islemetry, reopen it, and confirm the last selected language preference persists.

### Expected result

- The visible app interface uses the effective language.
- Metric names and localized state values change language.
- The language preference persists after reopening the app.
- Changing language does not clear the saved Dynamic Island metric or color configuration.

## App appearance test

1. Select **System**, **Light**, and **Dark** in the Appearance card.
2. In each mode, review the navigation bar, cards, segmented controls, labels, buttons, metric grid, and Dynamic Island preview.
3. In System mode, change the iPhone appearance in Control Center or Settings and return to Islemetry.
4. Force-quit and reopen Islemetry after selecting Dark.

### Expected result

- Light and Dark apply immediately without restarting.
- System follows the current iOS appearance.
- Text, materials, controls, and backgrounds retain readable contrast in all three modes.
- The Dynamic Island preview remains black and preserves its configured telemetry color.
- The selected appearance persists after reopening the app.

## Live Activity start test

1. Configure the Island as desired, including a non-white text color.
2. Start the Live Activity.
3. Return to the Home Screen.
4. Lock the iPhone and inspect the Lock Screen.
5. Unlock the iPhone and inspect the compact Dynamic Island.
6. Press and hold the Dynamic Island to inspect the expanded presentation.

### Expected result

- A Live Activity starts successfully.
- The compact Dynamic Island matches Leading and Trailing selections.
- The expanded presentation contains the expected selected metrics.
- The selected color is visible on Dynamic Island telemetry text/symbols.
- The Lock Screen presentation uses the selected telemetry color.
- No duplicate Live Activities are created unintentionally.

## Live Activity configuration and color update test

1. Keep the Live Activity running.
2. Change Leading, Trailing, expanded selections, and the text color in Islemetry.
3. Tap **Apply to Live Activity**.
4. Inspect compact, expanded, minimal when available, and Lock Screen presentations again.

### Expected result

- The existing Live Activity remains active.
- Its content updates to the newly selected layout.
- Its text/symbol color changes without ending the activity.
- Secondary labels use the same color at reduced opacity.
- No second Live Activity is created.

## Live Activity language update test

1. Keep the Live Activity running in English.
2. Open Islemetry and switch to **Español**.
3. Return to the Dynamic Island and expanded view.
4. Repeat with System mode and English.

### Expected result

- Islemetry automatically sends an updated ActivityKit state after the language change.
- Metric names and localized values shown by the Live Activity use the effective language.
- Auxiliary Live Activity text such as Updated / Actualizado changes appropriately.
- The custom color remains unchanged when language changes.
- The activity remains the same session and does not duplicate.

## Live Activity refresh test

1. Start a Live Activity and note the relative **Last snapshot** time.
2. Keep Islemetry in the foreground for at least four seconds without pressing a button.
3. Confirm that **Last snapshot** advances and check the Home preview and Live Activity.
4. Press **Refresh / Actualizar** and confirm that it still requests an immediate update.

### Expected result

- A new snapshot is captured approximately every three seconds while the app is active.
- The Home preview reflects the new snapshot.
- The Live Activity remains active.
- Updated values are sent automatically and after a manual refresh.
- The selected text color is preserved.
- Moving Islemetry to the background stops the three-second loop until the app becomes active again.

## Live Activity stop test

1. Press **Stop** in Islemetry.
2. Check the Dynamic Island.
3. Check the Lock Screen.

### Expected result

- The Live Activity ends cleanly.
- Islemetry disappears from the Dynamic Island.
- Islemetry disappears from the Lock Screen after the system completes the dismissal.

## Failure report template

```text
Test:
Device:
iOS:
Xcode:
Branch / commit:
Language:
Text color HEX:

Expected:

Actual:

Steps to reproduce:
1.
2.
3.

Xcode error or console output:

Screenshot / screen recording:
```

## V0.2 acceptance criteria

V0.2 hardware validation is successful when:

- The project builds and launches on a physical iPhone.
- All current metric cards render correctly.
- The Home Dynamic Island preview matches the saved configuration and selected color.
- Compact and expanded Island selections can be changed and persist.
- Dynamic Island text color can be changed, reset, applied, and persisted.
- System / English / Español language behavior works and persists.
- System / Light / Dark appearance works, remains readable, and persists.
- A running Live Activity updates when layout, color, or language changes.
- Compact, expanded, minimal, and Lock Screen presentations render correctly where available.
- The Live Activity can be refreshed and stopped without duplication or a stranded session.


## Location and local weather test

1. Install the latest build on a physical iPhone.
2. Open **Location & Weather**.
3. Tap **Allow Location** and grant access.
4. Tap **Refresh Weather**.
5. Confirm **Local Temperature**, **Feels Like**, **Weather**, and **Location** show values rather than a waiting state.
6. Assign **Local Temperature** to Compact Leading or Trailing.
7. Apply the configuration to a running Live Activity.
8. Confirm the temperature appears in the Dynamic Island.
9. Open the Open-Meteo attribution link.

### Expected result

- Permission state updates correctly.
- Local temperature is shown in °C.
- Apparent temperature and weather condition render correctly.
- The selected weather metric appears in the Live Activity.
- Attribution is visible and tappable.

## Background location test

1. Enable **Background location**.
2. Follow any additional iOS authorization prompt.
3. Confirm Islemetry reports **Always** if iOS grants it.
4. Keep a Live Activity running with Local Temperature selected.
5. Put Islemetry in the background.
6. Move far enough to generate a Core Location event, or use Xcode location simulation.
7. Re-check the existing Live Activity after iOS delivers the update.
8. Disable **Background location**.

### Expected result

- No duplicate Live Activity is created.
- Background location is active only when explicitly enabled.
- A delivered background location event can refresh weather and update the existing Live Activity.
- Disabling the switch stops standard background location updates.
- No fixed background interval is assumed; iOS controls scheduling.


## All-metric background refresh test

1. Install Islemetry 0.3.1 on a physical iPhone.
2. Start a Live Activity with metrics that are easy to observe changing, such as Battery, Power, Thermal, Network, Storage Free, and Local Temperature.
3. Confirm foreground refresh continues approximately every 3 seconds.
4. Send Islemetry to the background; do not force-quit it.
5. Confirm **Background App Refresh** is enabled for the device/app in iOS settings.
6. Leave the Live Activity running and allow iOS to execute the scheduled refresh task.
7. Reopen Islemetry and confirm the Live Activity was not duplicated.
8. If Background Location is enabled, a delivered location event should also update the complete telemetry snapshot.

### Expected result

- `BGTaskScheduler` registration does not crash at launch.
- The main target contains both `fetch` and `location` in `UIBackgroundModes`.
- `com.tiburonns.islemetry.refresh` is present in `BGTaskSchedulerPermittedIdentifiers`.
- A background task refreshes the full metric array and updates the existing Live Activity.
- Location events also refresh the full metric array before/with weather.
- No fixed 3-second or 15-minute background cadence is claimed; iOS decides actual execution timing.
