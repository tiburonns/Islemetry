#!/usr/bin/env python3
import json
import plistlib
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load_plist(relative: str):
    with (ROOT / relative).open("rb") as handle:
        return plistlib.load(handle)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"release contract failed: {message}")


info = load_plist("Islemetry/Info.plist")
privacy = load_plist("Islemetry/PrivacyInfo.xcprivacy")
widget = load_plist("IslemetryWidgets/Info.plist")
source = json.loads((ROOT / "altstore/source.json").read_text(encoding="utf-8"))
project = (ROOT / "Islemetry.xcodeproj/project.pbxproj").read_text(encoding="utf-8")

require(info.get("NSSupportsLiveActivities") is True, "Live Activities support is missing")

background_modes = set(info.get("UIBackgroundModes", []))
require({"fetch", "location"} <= background_modes, "background modes must include fetch and location")

identifiers = set(info.get("BGTaskSchedulerPermittedIdentifiers", []))
require(
    "com.tiburonns.islemetry.refresh" in identifiers,
    "BGTaskScheduler identifier is missing",
)

require(bool(info.get("NSLocationWhenInUseUsageDescription")), "when-in-use location disclosure is missing")
require(
    bool(info.get("NSLocationAlwaysAndWhenInUseUsageDescription")),
    "background location disclosure is missing",
)

require(privacy.get("NSPrivacyTracking") is False, "privacy manifest must declare no tracking")

required_reasons = {}
for entry in privacy.get("NSPrivacyAccessedAPITypes", []):
    required_reasons[entry.get("NSPrivacyAccessedAPIType")] = set(
        entry.get("NSPrivacyAccessedAPITypeReasons", [])
    )

require(
    "85F4.1" in required_reasons.get("NSPrivacyAccessedAPICategoryDiskSpace", set()),
    "disk-space required reason 85F4.1 is missing",
)
require(
    "CA92.1" in required_reasons.get("NSPrivacyAccessedAPICategoryUserDefaults", set()),
    "UserDefaults required reason CA92.1 is missing",
)

extension = widget.get("NSExtension", {})
require(
    extension.get("NSExtensionPointIdentifier") == "com.apple.widgetkit-extension",
    "WidgetKit extension point is invalid",
)

marketing_versions = set(re.findall(r"MARKETING_VERSION = ([0-9.]+);", project))
build_versions = set(re.findall(r"CURRENT_PROJECT_VERSION = ([0-9]+);", project))
require(len(marketing_versions) == 1, f"app/widget marketing versions diverge: {sorted(marketing_versions)}")
require(len(build_versions) == 1, f"app/widget build versions diverge: {sorted(build_versions)}")

apps = source.get("apps", [])
require(len(apps) == 1, "AltStore source must contain exactly one Islemetry app")
app = apps[0]
require(app.get("bundleIdentifier") == "com.tiburonns.islemetry", "AltStore bundle identifier drifted")

versions = app.get("versions", [])
version_names = [item.get("version") for item in versions]
require(len(version_names) == len(set(version_names)), "AltStore source contains duplicate versions")
for item in versions:
    require(bool(item.get("downloadURL")), f"AltStore {item.get('version')} is missing downloadURL")
    require(int(item.get("size", 0)) > 0, f"AltStore {item.get('version')} has invalid size")

print(
    "PASS: Islemetry release contract — "
    f"app/widget {next(iter(marketing_versions))} build {next(iter(build_versions))}, "
    f"{len(versions)} distributed AltStore version(s)"
)
