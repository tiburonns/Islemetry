#!/usr/bin/env python3
import json
import plistlib
import sys
import zipfile
from pathlib import Path


def require(value: bool, message: str) -> None:
    if not value:
        raise SystemExit(f"FAIL: {message}")


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("uso: validate_altstore.py <source.json> <ipa>")

    source_path = Path(sys.argv[1])
    ipa = Path(sys.argv[2])
    source = json.loads(source_path.read_text(encoding="utf-8"))
    app = source["apps"][0]
    version = app["versions"][0]

    with zipfile.ZipFile(ipa) as archive:
        names = set(archive.namelist())
        info = plistlib.loads(archive.read("Payload/Islemetry.app/Info.plist"))
        widget = plistlib.loads(
            archive.read("Payload/Islemetry.app/PlugIns/IslemetryWidgets.appex/Info.plist")
        )

    require(info["CFBundleIdentifier"] == app["bundleIdentifier"], "bundle ID de la app")
    require(info["CFBundleShortVersionString"] == version["version"], "versión")
    require(info["CFBundleVersion"] == version["buildVersion"], "build")
    require(info["MinimumOSVersion"] == version["minOSVersion"], "iOS mínimo")
    require(info["CFBundleSupportedPlatforms"] == ["iPhoneOS"], "plataforma física")
    background_modes = set(info.get("UIBackgroundModes", []))
    require({"fetch", "location"}.issubset(background_modes), "modos de segundo plano fetch + location")
    task_ids = info.get("BGTaskSchedulerPermittedIdentifiers", [])
    require(
        "com.tiburonns.islemetry.refresh" in task_ids,
        "identificador BGTaskScheduler de telemetría",
    )
    require("NSLocationWhenInUseUsageDescription" in info, "permiso de ubicación al usar")
    require(
        "NSLocationAlwaysAndWhenInUseUsageDescription" in info,
        "permiso de ubicación siempre",
    )
    require(widget["CFBundleIdentifier"] == "com.tiburonns.islemetry.widgets", "bundle ID del widget")
    require(widget["CFBundleVersion"] == info["CFBundleVersion"], "build del widget")
    require("Payload/Islemetry.app/PrivacyInfo.xcprivacy" in names, "privacy manifest")
    require("Payload/Islemetry.app/Assets.car" in names, "catálogo del icono")
    require(not any("_CodeSignature" in name for name in names), "IPA sin firmas")
    require(not any(name.endswith("embedded.mobileprovision") for name in names), "IPA sin perfiles")
    require(version["size"] == ipa.stat().st_size, "tamaño exacto")
    require(
        version["downloadURL"].startswith(
            "https://github.com/tiburonns/Islemetry/releases/download/"
        ),
        "URL de descarga",
    )
    require(app["appPermissions"] == {"entitlements": [], "privacy": {}}, "permisos declarados")
    print("PASS: IPA, widget, versión, background refresh, privacidad, icono y fuente AltStore")


if __name__ == "__main__":
    main()
