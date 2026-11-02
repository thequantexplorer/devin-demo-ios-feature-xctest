# Expenses

A small SwiftUI iPhone app for tracking expenses. It shows a list of expenses, newest first,
with a running total. You can add an expense and swipe to delete one.

- iOS 17+, SwiftUI, Observation
- Xcode 16 or later
- No third-party dependencies

## Layout

| Path | What it is |
| --- | --- |
| `Expenses/` | The app: models, store and views |
| `ExpensesTests/` | XCTest unit tests for the store |
| `ExpensesUITests/` | XCUITest UI tests |
| `docs/specs/` | Specs for upcoming features |
| `scripts/test.sh` | Builds the app and runs every test on an iPhone simulator |

## Run the tests

On a Mac with Xcode:

```sh
scripts/test.sh
```

The **Tests** GitHub Action runs the same script on every pull request.

## Next up

Search and sort for the expense list. See [docs/specs/search-and-sort.md](docs/specs/search-and-sort.md).

---

This repo is a starter for a Devin demo. See [DEVIN_DEMO.md](DEVIN_DEMO.md) for setup and the prompt.
