---
name: ios-simulator-testing
description: How to build, test and record the Expenses iOS app in the iOS Simulator. Use before opening a PR that changes the app or its tests.
---

This repo needs a macOS machine with Xcode. There are no dependencies to install.

## Run the tests

1. From the repo root run `scripts/test.sh`. It picks an available iPhone simulator and runs
   the `Expenses` scheme, which has both test targets: `ExpensesTests` (unit) and
   `ExpensesUITests` (UI).
2. Only unit tests: `scripts/test.sh -only-testing:ExpensesTests`.
3. A run is good only when it ends with `** TEST SUCCEEDED **`. Report the number of tests
   that ran, not just the last line.

## Add files

The Xcode project uses folder-synced groups. A new `.swift` file inside `Expenses/`,
`ExpensesTests/` or `ExpensesUITests/` is part of that target automatically. Do not edit
`project.pbxproj` to add files.

## Run the app in the Simulator

```bash
open -a Simulator
xcodebuild build -project Expenses.xcodeproj -scheme Expenses \
  -destination "id=<UDID>" -derivedDataPath build
xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/Expenses.app
xcrun simctl launch booted com.example.Expenses
```

Find the UDID with `xcrun simctl list devices booted`.

## Record a demo

Use your screen recording while you tap through the app in the Simulator window. If that is
not possible, `xcrun simctl io booted recordVideo demo.mp4` records the simulator screen
(stop it with Ctrl+C).

## Rules

- UI tests find elements by accessibility identifier. Add one for every new control a test
  needs.
- The sample data is fixed. Assert exact titles, order and totals.
