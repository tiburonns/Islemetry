# Islemetry IPA Guide

[Español](IPA.es.md) · **English**

This guide explains what an Islemetry `.ipa` is, how to create one from Xcode, and how it can be installed or distributed.

## What is an IPA?

An `.ipa` is an iOS application package. It contains the compiled Islemetry app and its embedded extension, including `IslemetryWidgets`.

A source-code checkout is not an IPA. The IPA must be produced from a successful Xcode archive and signed for the intended installation or distribution method.

## Important signing note

The repository does **not** contain private signing certificates, provisioning profiles, Apple account credentials, or a pre-signed universal IPA.

That is intentional. Signing material is account-specific and should never be committed to the repository.

## Option A — Install directly from Xcode

For development and testing, this is the simplest option and no IPA is required:

1. Connect the iPhone.
2. Select the `Islemetry` scheme.
3. Select the physical iPhone.
4. Configure signing for both app targets.
5. Press `⌘R`.

Xcode compiles, signs, installs, and launches Islemetry automatically.

## Option B — Create an IPA using Xcode Organizer

### 1. Select a generic iOS destination

In Xcode, select a distribution/archive destination such as a generic iOS device destination instead of a simulator.

### 2. Archive

Choose:

```text
Product → Archive
```

Wait for the archive to finish. Xcode should open Organizer automatically.

### 3. Validate the archive

In Organizer, confirm that the archive contains the Islemetry app and the `IslemetryWidgets` extension.

### 4. Distribute

Select:

```text
Distribute App
```

Xcode will offer the distribution choices available to your Apple Developer account and current project configuration.

Choose the option appropriate for your intended installation method, complete signing/provisioning, and export the result.

Depending on the selected export path, Xcode can produce an `.ipa` together with associated distribution metadata.

## Option C — Archive from Terminal

Advanced users can produce an Xcode archive from the command line:

```bash
xcodebuild \
  -project Islemetry.xcodeproj \
  -scheme Islemetry \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$PWD/build/Islemetry.xcarchive" \
  archive
```

The archive will be written to:

```text
build/Islemetry.xcarchive
```

Exporting that archive into an IPA requires a valid `ExportOptions.plist` that matches the signing/distribution method used by your Apple Developer account.

Example command:

```bash
xcodebuild \
  -exportArchive \
  -archivePath "$PWD/build/Islemetry.xcarchive" \
  -exportPath "$PWD/build/export" \
  -exportOptionsPlist ExportOptions.plist
```

Because export options vary by developer account and distribution method, Islemetry does not commit account-specific export credentials or profiles.

## Installing an exported IPA

How the IPA can be installed depends on how it was signed.

Common development/testing workflows include:

- Xcode installation directly to a registered device
- Apple-supported development or Ad Hoc distribution using appropriate provisioning
- TestFlight for beta distribution when configured through App Store Connect
- A sideloading tool that re-signs the app with the user's own Apple ID or certificate

The signing method determines which devices can launch the IPA and how long the signature/provisioning remains valid.

## Publishing an IPA on GitHub Releases

Before attaching an IPA to a GitHub Release:

1. Build and test the exact release commit on a physical iPhone.
2. Verify compact, expanded, and Lock Screen Live Activity presentations.
3. Confirm that the IPA includes `IslemetryWidgets.appex`.
4. Confirm the expected bundle identifiers and version/build numbers.
5. Do not publish private certificates, profiles, passwords, or API keys.
6. State clearly what signing method the binary uses and who can install it.

Suggested release asset name:

```text
Islemetry-v0.2.0.ipa
```

Suggested source archive name:

```text
Islemetry-v0.2.0-source.zip
```

## Release checklist

```text
[ ] Release commit tested on physical iPhone
[ ] App launches
[ ] Live Activity starts
[ ] Compact Dynamic Island works
[ ] Expanded Dynamic Island works
[ ] Lock Screen presentation works
[ ] Refresh works
[ ] Stop works
[ ] Language System / English / Español works
[ ] Dynamic Island selections persist
[ ] App icon is included
[ ] Privacy manifest is included
[ ] Correct version/build number
[ ] No signing secrets committed
[ ] IPA exported successfully
```

## Current repository status

The repository currently contains the source project and development documentation. A real distributable IPA should only be published after the current V0.2 branch completes on-device validation and a Release archive has been exported from Xcode with the intended signing configuration.
