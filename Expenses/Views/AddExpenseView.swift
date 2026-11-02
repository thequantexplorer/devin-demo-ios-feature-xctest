import SwiftUI

struct AddExpenseView: View {
    @Environment(ExpenseStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var amountText = ""
    @State private var category: Category = .food
    @State private var date = Date()

    private var amount: Decimal? { Money.parse(amountText) }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && (amount ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                    .accessibilityIdentifier("titleField")
                TextField("Amount", text: $amountText)
                    .keyboardType(.decimalPad)
                    .accessibilityIdentifier("amountField")
                Picker("Category", selection: $category) {
                    ForEach(Category.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let amount else { return }
                        if (try? store.add(title: title, amount: amount, category: category, date: date)) != nil {
                            dismiss()
                        }
                    }
                    .disabled(!canSave)
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}
