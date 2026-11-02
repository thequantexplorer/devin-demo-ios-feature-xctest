import Foundation

enum ExpenseSortOrder: String, CaseIterable, Identifiable {
    case newestFirst = "Newest first"
    case oldestFirst = "Oldest first"
    case amountHighToLow = "Amount: high to low"
    case amountLowToHigh = "Amount: low to high"
    case titleAToZ = "Title: A to Z"

    static let `default`: ExpenseSortOrder = .newestFirst

    var id: String { rawValue }
    var title: String { rawValue }

    /// Sorts by this order. Ties are always broken by title, A to Z.
    func sorted(_ expenses: [Expense]) -> [Expense] {
        expenses.sorted { lhs, rhs in
            switch primaryOrder(lhs, rhs) {
            case .orderedAscending: return true
            case .orderedDescending: return false
            case .orderedSame: return Self.titleThenID(lhs, rhs)
            }
        }
    }

    private func primaryOrder(_ lhs: Expense, _ rhs: Expense) -> ComparisonResult {
        switch self {
        case .newestFirst: Self.compare(rhs.date, lhs.date)
        case .oldestFirst: Self.compare(lhs.date, rhs.date)
        case .amountHighToLow: Self.compare(rhs.amount, lhs.amount)
        case .amountLowToHigh: Self.compare(lhs.amount, rhs.amount)
        case .titleAToZ: .orderedSame
        }
    }

    private static func compare<T: Comparable>(_ lhs: T, _ rhs: T) -> ComparisonResult {
        lhs < rhs ? .orderedAscending : (lhs > rhs ? .orderedDescending : .orderedSame)
    }

    private static func titleThenID(_ lhs: Expense, _ rhs: Expense) -> Bool {
        let byTitle = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
        if byTitle != .orderedSame { return byTitle == .orderedAscending }
        return lhs.id.uuidString < rhs.id.uuidString
    }
}

/// The search text and sort order for the expense list, and the pure logic that applies them.
struct ExpenseListQuery: Equatable {
    static let searchPrompt = "Search expenses"

    var searchText = ""
    var sortOrder: ExpenseSortOrder = .default

    /// The search text without leading or trailing whitespace.
    var normalizedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isSearching: Bool { !normalizedSearchText.isEmpty }

    /// True when the title or the category name contains the search text, ignoring case.
    /// An empty search matches every expense.
    func matches(_ expense: Expense) -> Bool {
        let needle = normalizedSearchText
        guard !needle.isEmpty else { return true }
        return expense.title.localizedCaseInsensitiveContains(needle)
            || expense.category.rawValue.localizedCaseInsensitiveContains(needle)
    }

    func filtered(_ expenses: [Expense]) -> [Expense] {
        expenses.filter(matches)
    }

    /// Filters by the search text, then sorts the results.
    func apply(to expenses: [Expense]) -> [Expense] {
        sortOrder.sorted(filtered(expenses))
    }

    /// True when the empty search state should be shown instead of the list.
    func showsNoResults(for results: [Expense]) -> Bool {
        isSearching && results.isEmpty
    }
}
