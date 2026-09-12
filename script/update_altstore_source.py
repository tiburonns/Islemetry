#!/usr/bin/env python3
import json
import plistlib
import sys
import zipfile
from datetime import datetime, timezone
from pathlib import Path


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("uso: update_altstore_source.py <ipa> <source.json>")

    ipa = Path(sys.argv[1])
    source_path = Path(sys.argv[2])

    with zipfile.ZipFile(ipa) as archive:
        info = plistlib.loads(archive.read("Payload/Islemetry.app/Info.plist"))

    source = json.loads(source_path.read_text(encoding="utf-8"))
    versions = source["apps"][0]["versions"]
    short_version = info["CFBundleShortVersionString"]
    version = next((item for item in versions if item["version"] == short_version), None)
    if version is None:
        version = {
            "version": short_version,
            "buildVersion": info["CFBundleVersion"],
            "date": datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z"),
            "localizedDescription": "Actualización de estabilidad: refresco automático eficiente cada tres segundos y actualizaciones inmediatas cuando cambian las métricas visibles.",
            "downloadURL": "",
            "size": 0,
            "minOSVersion": info["MinimumOSVersion"],
        }
        versions.insert(0, version)
    version["version"] = short_version
    version["buildVersion"] = info["CFBundleVersion"]
    version["minOSVersion"] = info["MinimumOSVersion"]
    version["size"] = ipa.stat().st_size
    version["downloadURL"] = (
        "https://github.com/tiburonns/Islemetry/releases/download/"
        f"v{version['version']}/Islemetry-{version['version']}.ipa"
    )

    source_path.write_text(
        json.dumps(source, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
