# Devin demo: add a feature to an iOS app, with tests and a recording

**What it shows:** Devin works on a macOS machine with Xcode. It adds search and sorting to a
SwiftUI app, writes unit tests and UI tests, runs them in the iOS Simulator, and sends you a
video of the feature working.

**Needs:** GitHub, and a Devin plan with macOS sessions (Pro and Teams have them by default).

More demos: [devin-advanced-demos](https://github.com/thequantexplorer/devin-advanced-demos)

## What's in the repo

- `Expenses/`: a small SwiftUI expenses app. The list shows every expense, newest first.
  There is no search and no way to change the order.
- `ExpensesTests/` and `ExpensesUITests/`: 9 XCTest tests that pass today.
- `docs/specs/search-and-sort.md`: the spec for the feature, with 11 acceptance criteria.
- `.agents/skills/ios-simulator-testing/SKILL.md`: a repo skill that tells Devin how to build,
  test and record this app.
- `.github/workflows/tests.yml`: runs the tests on a macOS runner for every pull request.

## Set it up

1. Click **Use this template → Create a new repository**, choose your GitHub account or org as
   the owner, and keep the name `devin-demo-ios-feature-xctest`. The prompt below assumes that
   name. Use the template rather than a fork: pull requests on a fork go to the original repo
   by default.
2. In Devin, open [**Settings → Connections → GitHub**](https://app.devin.ai/settings/connections/github)
   and make sure Devin can access the new repository.
3. Open [app.devin.ai](https://app.devin.ai). In the platform menu below the prompt box, choose
   **macOS**.

## Prompt

Paste this into the prompt box. Replace `<you>` with your GitHub user or org.

```text
Repo: https://github.com/<you>/devin-demo-ios-feature-xctest

This is a small SwiftUI expenses app with XCTest unit and UI tests. Add search and sorting to the expense list, as described in docs/specs/search-and-sort.md. Work in this macOS session. If this session is not on macOS, start a macOS child session for the Xcode work.

1. Run scripts/test.sh first and show me the result before you change anything.
2. Build the feature. Keep the search and sort logic out of the view so unit tests can call it.
3. Write unit tests for the search and sort rules in the spec, and UI tests that type a search and change the sort order.
4. Run all the tests in the iOS Simulator with scripts/test.sh until they pass.
5. Run the app in the Simulator and record a short video: search for "food", clear the search, then sort by "Amount: high to low". Send me the video.
6. Open a PR. In the description, list each acceptance criterion with the test that covers it, and paste the final test summary.
```

## What to watch

- Devin runs the existing tests before it changes any code.
- The **iOS Simulator** in the session shows the app while Devin taps through it.

## Done when

- The PR adds search and sorting, with new unit and UI tests, and the **Tests** check is green.
- Devin sent a video of search and sorting working in the Simulator.
