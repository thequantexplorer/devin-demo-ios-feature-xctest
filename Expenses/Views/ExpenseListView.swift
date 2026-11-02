import SwiftUI

struct ExpenseListView: View {
    @Environment(ExpenseStore.self) private var store
    @State private var isAdding = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Total")
                        Spacer()
                        Text(Money.format(store.total))
                            .font(.headline.monospacedDigit())
                            .accessibilityIdentifier("totalAmount")
                    }
                }
                Section("Expenses") {
                    ForEach(store.expensesNewestFirst) { expense in
                        ExpenseRow(expense: expense)
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    store.delete(expense)
                                }
                            }
                    }
                }
            }
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAdding = true
                    } label: {
                        Label("Add Expense", systemImage: "plus")
                    }
                    .accessibilityIdentifier("addExpenseButton")
                }
            }
            .sheet(isPresented: $isAdding) {
                AddExpenseView()
            }
        }
    }
}

#Preview {
    ExpenseListView()
        .environment(ExpenseStore())
}
