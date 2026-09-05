# Getting Started with Islemetry

[Español](GETTING_STARTED.es.md) · **English**

This guide explains how to clone Islemetry, open it in Xcode, configure signing, build it, and install it on a physical iPhone.

## Requirements

- A Mac capable of running a recent Xcode release
- Xcode 26 or later recommended
- iOS 17 or later on the target iPhone
- An Apple ID added to Xcode
- A physical iPhone for full Live Activity / Dynamic Island validation

A paid Apple Developer Program membership is not required just to open the project or perform ordinary local development. Distribution methods may require additional signing, provisioning, or a paid membership depending on the export method.

## 1. Clone the repository

Using Terminal:

```bash
git clone https://github.com/tiburonns/Islemetry.git
cd Islemetry
```

The active development work currently lives on:

```bash
git switch bootstrap/v0.1
```

If the branch has already been merged into `main`, simply use:

```bash
git switch main
```

To update an existing local copy:

```bash
git fetch origin
git pull
```

## 2. Open the Xcode project

From Terminal:

```bash
open Islemetry.xcodeproj
```

Or open `Islemetry.xcodeproj` directly from Finder.

The project contains two main targets:

- `Islemetry` — the iOS app
- `IslemetryWidgets` — the WidgetKit / ActivityKit extension that renders the Live Activity and Dynamic Island UI

## 3. Configure signing

In Xcode:

1. Select the **Islemetry** project in the navigator.
2. Select the **Islemetry** target.
3. Open **Signing & Capabilities**.
4. Enable **Automatically manage signing**.
5. Select your Apple Developer team.
6. Repeat the process for **IslemetryWidgets**.

Current bundle identifiers are:

```text
com.tiburonns.islemetry
com.tiburonns.islemetry.widgets
```

If Xcode reports that a bundle identifier is unavailable for your account, replace it with your own unique reverse-domain identifier for both targets.

Example:

```text
com.yourname.islemetry
com.yourname.islemetry.widgets
```

Keep the widget identifier related to the main application identifier.

## 4. Select the iPhone

1. Connect the iPhone to the Mac.
2. Trust the Mac if iOS asks.
3. Select the physical iPhone as the Xcode run destination.
4. Enable Developer Mode on the iPhone if iOS requests it.

## 5. Build and install

In Xcode, press:

```text
⌘R
```

or select:

```text
Product → Run
```

Xcode should build the app, embed the `IslemetryWidgets` extension, install Islemetry on the iPhone, and launch it.

## 6. First test

After installation:

1. Open Islemetry.
2. Confirm that the device metrics are visible.
3. Configure the Dynamic Island metrics.
4. Choose **System**, **English**, or **Español** under Language.
5. Start the Live Activity.
6. Return to the Home Screen.
7. Check the compact Dynamic Island.
8. Press and hold the Dynamic Island to open its expanded presentation.
9. Lock the iPhone and verify the Lock Screen Live Activity.
10. Return to Islemetry and use **Refresh** to push a fresh telemetry snapshot.

The complete device validation checklist is available in [TESTING.md](TESTING.md).

## 7. Updating the project later

Before pulling new changes, commit or stash any local work.

Then:

```bash
git fetch origin
git pull
```

If working on the development branch:

```bash
git switch bootstrap/v0.1
git pull origin bootstrap/v0.1
```

## Common issues

### Signing error

Confirm that both targets use the same Apple Developer team and that each target has a unique bundle identifier.

### Widget extension does not install

Build the main `Islemetry` target, not the extension by itself. The extension is embedded into the application during the normal app build.

### Live Activity does not appear

Confirm that Live Activities are enabled for Islemetry in iOS settings and that you are testing on a physical device. Dynamic Island presentation additionally requires an iPhone model with Dynamic Island hardware.

### Dynamic Island still shows old values

Open Islemetry and use **Refresh**, or change the configuration and choose **Apply to Live Activity**. Many device metrics are snapshots because iOS does not allow Islemetry to run continuously as a desktop-style system monitor while suspended.

## IPA distribution

Running directly from Xcode does not require an `.ipa` file. If you want a distributable package, see [IPA.md](IPA.md).
