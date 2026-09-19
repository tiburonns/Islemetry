#!/bin/zsh
set -euo pipefail

repo_root="${0:A:h:h}"
tmp_dir="$(mktemp -d /tmp/islemetry-core-tests.XXXXXX)"
trap 'rm -rf "$tmp_dir"' EXIT

xcrun swiftc   "$repo_root/Shared/BackgroundRefreshOutcome.swift"   "$repo_root/Tests/BackgroundRefreshOutcomeTests.swift"   -o "$tmp_dir/islemetry-core-tests"

"$tmp_dir/islemetry-core-tests"
