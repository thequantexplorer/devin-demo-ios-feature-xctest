import Foundation
import Observation

enum ExpenseError: Error, Equatable {
    case emptyTitle
    case nonPositiveAmount
}

@Observable
final class ExpenseStore {
    private(set) var expenses: [Expense]

    init(expenses: [Expense] = SampleData.expenses) {
        self.expenses = expenses
    }

    /// Newest first. Expenses on the same day are ordered by title, A to Z.
    var expensesNewestFirst: [Expense] {
        ExpenseSortOrder.newestFirst.sorted(expenses)
    }

    var total: Decimal {
        Self.total(of: expenses)
    }

    static func total(of expenses: [Expense]) -> Decimal {
        expenses.reduce(0) { $0 + $1.amount }
    }

    @discardableResult
    func add(title: String, amount: Decimal, category: Category, date: Date) throws -> Expense {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ExpenseError.emptyTitle }
        guard amount > 0 else { throw ExpenseError.nonPositiveAmount }
        let expense = Expense(title: trimmed, amount: amount, category: category, date: date)
        expenses.append(expense)
        return expense
    }

    func delete(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
    }
}
