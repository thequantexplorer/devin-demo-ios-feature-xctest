#!/usr/bin/env bash
# Builds the app and runs the unit and UI tests on an iPhone simulator.
# Usage: scripts/test.sh [extra xcodebuild args], e.g. scripts/test.sh -only-testing:ExpensesTests
# Set SIMULATOR_ID to a device UDID to pick the simulator yourself.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -z "${SIMULATOR_ID:-}" ]]; then
  SIMULATOR_ID=$(xcrun simctl list devices available -j | python3 -c '
import json, re, sys
devices = json.load(sys.stdin)["devices"]
phones = []
for runtime, items in devices.items():
    m = re.search(r"iOS-(\d+)-(\d+)", runtime)
    if not m:
        continue
    for d in items:
        if d["name"].startswith("iPhone"):
            booted = d["state"] == "Booted"
            phones.append((booted, int(m.group(1)), int(m.group(2)), d["udid"], d["name"]))
if not phones:
    sys.exit("No available iPhone simulator. Run: xcrun simctl list devices available")
phones.sort(reverse=True)
print(phones[0][3])
')
fi

echo "Using simulator $SIMULATOR_ID"
xcodebuild test \
  -project Expenses.xcodeproj \
  -scheme Expenses \
  -destination "id=$SIMULATOR_ID" \
  -derivedDataPath build \
  "$@"
