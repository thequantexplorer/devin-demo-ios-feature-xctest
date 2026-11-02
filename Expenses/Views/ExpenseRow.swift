import SwiftUI

struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category.symbolName)
                .foregroundStyle(.tint)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.body)
                Text("\(expense.category.rawValue) · \(expense.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(Money.format(expense.amount))
                .font(.body.monospacedDigit())
        }
    }
}
