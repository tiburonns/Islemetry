#!/usr/bin/env python3
import json
import plistlib
import sys
import zipfile
from pathlib import Path


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("uso: update_altstore_source.py <ipa> <source.json>")

    ipa = Path(sys.argv[1])
    source_path = Path(sys.argv[2])

    with zipfile.ZipFile(ipa) as archive:
        info = plistlib.loads(archive.read("Payload/Islemetry.app/Info.plist"))

    source = json.loads(source_path.read_text(encoding="utf-8"))
    version = source["apps"][0]["versions"][0]
    version["version"] = info["CFBundleShortVersionString"]
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
