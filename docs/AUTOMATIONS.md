# Shortcuts Automations

Islemetry 0.4.0 exposes the **Refresh Islemetry** App Intent to Apple Shortcuts.

The intent refreshes the complete available telemetry snapshot and updates the existing Live Activity. An automation triggered by the charger, Wi-Fi, Bluetooth, Low Power Mode, battery level, Focus, Airplane Mode, or another supported personal-automation trigger therefore refreshes all Islemetry modules that iOS lets the app read at that moment.

## First launch

Install and launch Islemetry 0.4.0 at least once. Islemetry registers its App Shortcut with the system during launch.

Inside Islemetry, open the **Shortcuts Automations** card and tap the Shortcuts button. The **Refresh Islemetry** action should appear on Islemetry's Shortcuts page.

## Recommended automations

Create each automation in **Shortcuts → Automation → +**. Choose the trigger, select **Run Immediately**, then add the **Refresh Islemetry** action.

Recommended starting set:

1. Charger → Is Connected
2. Charger → Is Disconnected
3. Wi-Fi → Any Network
4. Bluetooth → Any Device, or selected devices
5. Low Power Mode → Is Turned On
6. Low Power Mode → Is Turned Off
7. Battery Level → Falls Below 20%
8. Battery Level → Rises Above 80%
9. Airplane Mode → Is Turned On
10. Airplane Mode → Is Turned Off

You can also use Focus, CarPlay, NFC, app-open/app-close and other personal automation triggers when useful.

## What happens when an automation fires

The automation runs **Refresh Islemetry**. Islemetry then:

1. Reads a complete current telemetry snapshot.
2. Gives the network monitor a brief opportunity to publish the current path.
3. Updates the existing ActivityKit Live Activity.
4. Reuses the latest authorized location to refresh weather when appropriate.
5. Stores the automation start, completion and result so the app can show diagnostics.

The trigger does not update only its own metric. For example, a Charger automation causes Islemetry to reread battery, charging state, network, thermal state, storage, display, device/system information, location/weather cache and all other available metrics.

## Important iOS behavior

App Intents are designed to work from system experiences including Shortcuts, and Islemetry requests background execution for the refresh action on supported iOS versions. The system still controls runtime resources and can cancel work under exceptional conditions.

Personal automations are device-specific. Create them on each iPhone or iPad where you want them to run.
