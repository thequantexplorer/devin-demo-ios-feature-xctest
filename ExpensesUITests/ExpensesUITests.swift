import XCTest

final class ExpensesUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testLaunchShowsSampleExpensesAndTotal() {
        XCTAssertTrue(app.navigationBars["Expenses"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.staticTexts["totalAmount"].label, "$621.64")
        XCTAssertTrue(app.staticTexts["Coffee beans"].exists)
    }

    func testAddExpenseUpdatesListAndTotal() {
        app.buttons["addExpenseButton"].tap()

        let title = app.textFields["titleField"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        title.tap()
        title.typeText("Bike repair")

        let amount = app.textFields["amountField"]
        amount.tap()
        amount.typeText("30")

        app.buttons["saveButton"].tap()

        XCTAssertTrue(app.staticTexts["Bike repair"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["totalAmount"].label, "$651.64")
    }
}
