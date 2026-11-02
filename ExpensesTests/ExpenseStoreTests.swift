import XCTest
@testable import Expenses

final class ExpenseStoreTests: XCTestCase {
    private var store: ExpenseStore!

    override func setUp() {
        super.setUp()
        store = ExpenseStore()
    }

    func testSampleDataTotal() {
        XCTAssertEqual(store.expenses.count, 10)
        XCTAssertEqual(store.total, SampleData.usd("621.64"))
        XCTAssertEqual(Money.format(store.total), "$621.64")
    }

    func testNewestFirstBreaksTiesByTitle() {
        let titles = store.expensesNewestFirst.map(\.title)
        XCTAssertEqual(Array(titles.prefix(3)), ["Coffee beans", "Movie night", "Groceries"])
        XCTAssertEqual(titles.last, "Train pass")
    }

    func testAddTrimsTitleAndUpdatesTotal() throws {
        let expense = try store.add(title: "  Bike repair ", amount: SampleData.usd("30.00"), category: .transport, date: SampleData.day(2026, 10, 31))
        XCTAssertEqual(expense.title, "Bike repair")
        XCTAssertEqual(store.expenses.count, 11)
        XCTAssertEqual(store.total, SampleData.usd("651.64"))
        XCTAssertEqual(store.expensesNewestFirst.first?.title, "Bike repair")
    }

    func testAddRejectsEmptyTitle() {
        XCTAssertThrowsError(try store.add(title: "   ", amount: 5, category: .food, date: .now)) { error in
            XCTAssertEqual(error as? ExpenseError, .emptyTitle)
        }
        XCTAssertEqual(store.expenses.count, 10)
    }

    func testAddRejectsZeroOrNegativeAmount() {
        XCTAssertThrowsError(try store.add(title: "Refund", amount: 0, category: .food, date: .now))
        XCTAssertThrowsError(try store.add(title: "Refund", amount: -5, category: .food, date: .now))
        XCTAssertEqual(store.expenses.count, 10)
    }

    func testDeleteRemovesOnlyThatExpense() throws {
        let lamp = try XCTUnwrap(store.expenses.first { $0.title == "Desk lamp" })
        store.delete(lamp)
        XCTAssertEqual(store.expenses.count, 9)
        XCTAssertFalse(store.expenses.contains(lamp))
        XCTAssertEqual(store.total, SampleData.usd("585.65"))
    }

    func testMoneyParse() {
        XCTAssertEqual(Money.parse("12.5"), SampleData.usd("12.5"))
        XCTAssertEqual(Money.parse("$1,200.00"), SampleData.usd("1200"))
        XCTAssertNil(Money.parse(""))
        XCTAssertNil(Money.parse("abc"))
    }
}
