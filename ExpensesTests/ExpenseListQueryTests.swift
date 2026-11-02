import XCTest
@testable import Expenses

/// One test per search and sort rule in docs/specs/search-and-sort.md.
final class ExpenseListQueryTests: XCTestCase {
    private let sample = SampleData.expenses

    private func titles(_ query: ExpenseListQuery, in expenses: [Expense]? = nil) -> [String] {
        query.apply(to: expenses ?? sample).map(\.title)
    }

    private func titles(search: String = "", sort: ExpenseSortOrder = .default) -> [String] {
        titles(ExpenseListQuery(searchText: search, sortOrder: sort))
    }

    // MARK: - Search

    // Criterion 1
    func testSearchPromptIsSearchExpenses() {
        XCTAssertEqual(ExpenseListQuery.searchPrompt, "Search expenses")
    }

    // Criterion 2
    func testSearchMatchesTitle() {
        XCTAssertEqual(titles(search: "lamp"), ["Desk lamp"])
    }

    // Criterion 2
    func testSearchMatchesCategoryName() {
        XCTAssertEqual(titles(search: "food"), ["Coffee beans", "Groceries"])
    }

    // Criterion 3
    func testSearchIgnoresCase() {
        XCTAssertEqual(titles(search: "COFFEE"), ["Coffee beans"])
        XCTAssertEqual(titles(search: "FoOd"), ["Coffee beans", "Groceries"])
    }

    // Criterion 3
    func testSearchIgnoresLeadingAndTrailingSpaces() {
        XCTAssertEqual(titles(search: "  COFFEE "), ["Coffee beans"])
    }

    // Criterion 4
    func testEmptySearchShowsEveryExpense() {
        XCTAssertEqual(titles(search: "").count, 10)
        XCTAssertEqual(titles(search: "   ").count, 10)
        XCTAssertFalse(ExpenseListQuery(searchText: "   ").isSearching)
    }

    // Criterion 5
    func testSearchWithNoMatchesShowsEmptySearchState() {
        let query = ExpenseListQuery(searchText: "zzz")
        let results = query.apply(to: sample)
        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(query.showsNoResults(for: results))
    }

    // Criterion 5 (counterpart): no empty state when there is no search, even with no expenses.
    func testEmptyStateIsOnlyForSearchesWithNoMatches() {
        XCTAssertFalse(ExpenseListQuery(searchText: "food").showsNoResults(for: ExpenseListQuery(searchText: "food").apply(to: sample)))
        XCTAssertFalse(ExpenseListQuery(searchText: "").showsNoResults(for: []))
    }

    // Criterion 6
    func testTotalIsSumOfShownExpenses() {
        let shown = ExpenseListQuery(searchText: "transport").apply(to: sample)
        XCTAssertEqual(ExpenseStore.total(of: shown), SampleData.usd("133.75"))
        XCTAssertEqual(Money.format(ExpenseStore.total(of: shown)), "$133.75")
        XCTAssertEqual(Money.format(ExpenseStore.total(of: ExpenseListQuery().apply(to: sample))), "$621.64")
    }

    // MARK: - Sort

    // Criterion 7
    func testSortOptionsAreInSpecOrder() {
        XCTAssertEqual(ExpenseSortOrder.allCases.map(\.title), [
            "Newest first",
            "Oldest first",
            "Amount: high to low",
            "Amount: low to high",
            "Title: A to Z",
        ])
    }

    // Criterion 7
    func testDefaultSortIsNewestFirst() {
        XCTAssertEqual(ExpenseSortOrder.default, .newestFirst)
        XCTAssertEqual(ExpenseListQuery().sortOrder, .newestFirst)
    }

    // Criterion 7
    func testSortNewestFirst() {
        XCTAssertEqual(titles(sort: .newestFirst), [
            "Coffee beans", "Movie night", "Groceries", "Team lunch", "Taxi to airport",
            "Concert tickets", "Electricity bill", "Pharmacy", "Desk lamp", "Train pass",
        ])
    }

    // Criterion 7
    func testSortOldestFirst() {
        XCTAssertEqual(titles(sort: .oldestFirst), [
            "Train pass", "Desk lamp", "Pharmacy", "Electricity bill", "Concert tickets",
            "Taxi to airport", "Team lunch", "Groceries", "Coffee beans", "Movie night",
        ])
    }

    // Criterion 7
    func testSortAmountHighToLow() {
        XCTAssertEqual(titles(sort: .amountHighToLow), [
            "Concert tickets", "Electricity bill", "Train pass", "Groceries", "Team lunch",
            "Taxi to airport", "Desk lamp", "Movie night", "Coffee beans", "Pharmacy",
        ])
    }

    // Criterion 7
    func testSortAmountLowToHigh() {
        XCTAssertEqual(titles(sort: .amountLowToHigh), [
            "Coffee beans", "Pharmacy", "Movie night", "Desk lamp", "Taxi to airport",
            "Team lunch", "Groceries", "Train pass", "Electricity bill", "Concert tickets",
        ])
    }

    // Criterion 7
    func testSortTitleAToZ() {
        XCTAssertEqual(titles(sort: .titleAToZ), [
            "Coffee beans", "Concert tickets", "Desk lamp", "Electricity bill", "Groceries",
            "Movie night", "Pharmacy", "Taxi to airport", "Team lunch", "Train pass",
        ])
    }

    // Criterion 9: the spec's example.
    func testAmountLowToHighBreaksTiesByTitle() {
        XCTAssertEqual(Array(titles(sort: .amountLowToHigh).prefix(2)), ["Coffee beans", "Pharmacy"])
    }

    // Criterion 9: ties go A to Z even when the primary order is descending.
    func testAmountHighToLowBreaksTiesByTitle() {
        XCTAssertEqual(Array(titles(sort: .amountHighToLow).suffix(2)), ["Coffee beans", "Pharmacy"])
    }

    // Criterion 9: same-day expenses ("Coffee beans" and "Movie night" on Oct 30).
    func testDateSortsBreakTiesByTitle() {
        XCTAssertEqual(Array(titles(sort: .newestFirst).prefix(2)), ["Coffee beans", "Movie night"])
        XCTAssertEqual(Array(titles(sort: .oldestFirst).suffix(2)), ["Coffee beans", "Movie night"])
    }

    // Criterion 9: every option, with expenses that tie on date and amount.
    func testEverySortOrderBreaksTiesByTitle() {
        let day = SampleData.day(2026, 10, 5)
        let tied = ["zebra", "Apple", "mango"].map {
            Expense(title: $0, amount: 10, category: .fun, date: day)
        }
        for order in ExpenseSortOrder.allCases {
            XCTAssertEqual(order.sorted(tied).map(\.title), ["Apple", "mango", "zebra"], order.title)
        }
    }

    // MARK: - Search and sort together

    // Criterion 10
    func testSortAppliesToSearchResults() {
        XCTAssertEqual(titles(search: "food", sort: .amountHighToLow), ["Groceries", "Coffee beans"])
        XCTAssertEqual(titles(search: "transport", sort: .amountHighToLow), ["Train pass", "Taxi to airport"])
        XCTAssertEqual(titles(search: "transport", sort: .oldestFirst), ["Train pass", "Taxi to airport"])
        XCTAssertEqual(titles(search: "transport", sort: .titleAToZ), ["Taxi to airport", "Train pass"])
    }

    // Criterion 11
    func testAddingAnExpenseKeepsSearchAndSort() throws {
        let store = ExpenseStore()
        let query = ExpenseListQuery(searchText: "food", sortOrder: .amountHighToLow)
        try store.add(title: "Bagels", amount: SampleData.usd("30.00"), category: .food, date: SampleData.day(2026, 10, 31))
        try store.add(title: "Bus ticket", amount: SampleData.usd("3.00"), category: .transport, date: SampleData.day(2026, 10, 31))
        XCTAssertEqual(query.apply(to: store.expenses).map(\.title), ["Groceries", "Bagels", "Coffee beans"])
    }

    // Criterion 11
    func testDeletingAnExpenseKeepsSearchAndSort() throws {
        let store = ExpenseStore()
        let query = ExpenseListQuery(searchText: "o", sortOrder: .amountLowToHigh)
        let movie = try XCTUnwrap(store.expenses.first { $0.title == "Movie night" })
        store.delete(movie)
        XCTAssertEqual(query.apply(to: store.expenses).map(\.title), [
            "Coffee beans", "Desk lamp", "Taxi to airport", "Team lunch", "Groceries",
            "Train pass", "Electricity bill", "Concert tickets",
        ])
    }
}
