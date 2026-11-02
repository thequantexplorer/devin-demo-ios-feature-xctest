import XCTest

final class SearchAndSortUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.navigationBars["Expenses"].waitForExistence(timeout: 10))
    }

    // MARK: - Helpers

    /// `.searchable` has no API for an accessibility identifier, so the field is found by its prompt.
    private var searchField: XCUIElement { app.searchFields["Search expenses"] }
    private var total: String { app.staticTexts["totalAmount"].label }

    private func search(_ text: String) {
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText(text)
    }

    private func clearSearch() {
        let clear = searchField.buttons["Clear text"]
        if clear.exists {
            clear.tap()
        } else {
            let length = (searchField.value as? String)?.count ?? 0
            searchField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: length))
        }
    }

    private func dismissKeyboard() {
        searchField.typeText("\n")
    }

    private func openSortMenu() {
        app.buttons["sortMenu"].tap()
        XCTAssertTrue(app.buttons["Newest first"].waitForExistence(timeout: 5))
    }

    private func sort(by option: String) {
        openSortMenu()
        app.buttons[option].tap()
        XCTAssertTrue(app.buttons[option].waitForNonExistence(timeout: 5))
    }

    /// Asserts these titles are shown, top to bottom, in this order.
    private func assertOrder(_ titles: [String], file: StaticString = #filePath, line: UInt = #line) {
        var previousY = -CGFloat.infinity
        for title in titles {
            let text = app.staticTexts[title]
            XCTAssertTrue(text.waitForExistence(timeout: 5), "\(title) is not shown", file: file, line: line)
            XCTAssertGreaterThan(text.frame.minY, previousY, "\(title) is out of order", file: file, line: line)
            previousY = text.frame.minY
        }
    }

    private func assertNotShown(_ titles: [String], file: StaticString = #filePath, line: UInt = #line) {
        for title in titles {
            XCTAssertFalse(app.staticTexts[title].exists, "\(title) should be hidden", file: file, line: line)
        }
    }

    // MARK: - Search

    func testSearchFieldHasPrompt() {
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        XCTAssertEqual(searchField.placeholderValue, "Search expenses")
    }

    func testSearchFoodMatchesTitleAndCategory() {
        search("food")
        assertOrder(["Coffee beans", "Groceries"])
        assertNotShown(["Train pass", "Movie night", "Pharmacy"])
        XCTAssertEqual(total, "$82.70")
    }

    func testSearchIgnoresCaseAndSurroundingSpaces() {
        search("  COFFEE ")
        assertOrder(["Coffee beans"])
        assertNotShown(["Groceries", "Movie night"])
        XCTAssertEqual(total, "$18.50")
    }

    func testClearingSearchShowsEveryExpense() {
        search("food")
        XCTAssertTrue(app.staticTexts["Movie night"].waitForNonExistence(timeout: 5))
        clearSearch()
        assertOrder(["Coffee beans", "Movie night", "Groceries", "Team lunch"])
        XCTAssertEqual(total, "$621.64")
    }

    func testSearchWithNoMatchesShowsEmptySearchState() {
        search("zzz")
        let noResults = app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH 'No Results'")).firstMatch
        XCTAssertTrue(noResults.waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["totalAmount"].exists)
        assertNotShown(["Coffee beans", "Groceries"])
    }

    func testTotalShowsSumOfSearchResults() {
        search("transport")
        assertOrder(["Taxi to airport", "Train pass"])
        XCTAssertEqual(total, "$133.75")
    }

    // MARK: - Sort

    func testSortMenuListsOptionsInOrderWithCheckmarkOnCurrent() {
        openSortMenu()
        let options = ["Newest first", "Oldest first", "Amount: high to low", "Amount: low to high", "Title: A to Z"]
        var previousY = -CGFloat.infinity
        for option in options {
            let button = app.buttons[option]
            XCTAssertTrue(button.exists, option)
            XCTAssertGreaterThan(button.frame.minY, previousY, option)
            previousY = button.frame.minY
        }
        XCTAssertTrue(app.buttons["Newest first"].isSelected)
        XCTAssertFalse(app.buttons["Amount: high to low"].isSelected)

        app.buttons["Amount: high to low"].tap()
        openSortMenu()
        XCTAssertTrue(app.buttons["Amount: high to low"].isSelected)
        XCTAssertFalse(app.buttons["Newest first"].isSelected)
    }

    func testSortAmountHighToLow() {
        sort(by: "Amount: high to low")
        assertOrder(["Concert tickets", "Electricity bill", "Train pass", "Groceries", "Team lunch"])
        XCTAssertEqual(total, "$621.64")
    }

    func testSortAmountLowToHighBreaksTiesByTitle() {
        sort(by: "Amount: low to high")
        assertOrder(["Coffee beans", "Pharmacy", "Movie night", "Desk lamp"])
    }

    func testSortOldestFirst() {
        sort(by: "Oldest first")
        assertOrder(["Train pass", "Desk lamp", "Pharmacy", "Electricity bill"])
    }

    func testSortTitleAToZ() {
        sort(by: "Title: A to Z")
        assertOrder(["Coffee beans", "Concert tickets", "Desk lamp", "Electricity bill"])
    }

    // MARK: - Together

    func testSortAppliesToSearchResults() {
        search("food")
        assertOrder(["Coffee beans", "Groceries"])
        sort(by: "Amount: high to low")
        assertOrder(["Groceries", "Coffee beans"])
        XCTAssertEqual(searchField.value as? String, "food")
        XCTAssertEqual(total, "$82.70")
    }

    func testAddAndDeleteKeepSearchAndSort() {
        search("food")
        dismissKeyboard()
        sort(by: "Amount: high to low")

        app.buttons["addExpenseButton"].tap()
        let title = app.textFields["titleField"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        title.tap()
        title.typeText("Bagels")
        let amount = app.textFields["amountField"]
        amount.tap()
        amount.typeText("30")
        app.buttons["saveButton"].tap()

        assertOrder(["Groceries", "Bagels", "Coffee beans"])
        XCTAssertEqual(total, "$112.70")
        XCTAssertEqual(searchField.value as? String, "food")

        let groceries = app.cells.containing(.staticText, identifier: "Groceries").firstMatch
        groceries.swipeLeft()
        app.buttons["Delete"].tap()

        XCTAssertTrue(app.staticTexts["Groceries"].waitForNonExistence(timeout: 5))
        assertOrder(["Bagels", "Coffee beans"])
        XCTAssertEqual(total, "$48.50")
        XCTAssertEqual(searchField.value as? String, "food")

        openSortMenu()
        XCTAssertTrue(app.buttons["Amount: high to low"].isSelected)
    }
}
