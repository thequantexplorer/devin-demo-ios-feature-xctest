import SwiftUI

struct ExpenseListView: View {
    @Environment(ExpenseStore.self) private var store
    @State private var isAdding = false
    @State private var query = ExpenseListQuery()

    var body: some View {
        let shown = query.apply(to: store.expenses)

        NavigationStack {
            Group {
                if query.showsNoResults(for: shown) {
                    ContentUnavailableView.search(text: query.normalizedSearchText)
                } else {
                    List {
                        Section {
                            HStack {
                                Text("Total")
                                Spacer()
                                Text(Money.format(ExpenseStore.total(of: shown)))
                                    .font(.headline.monospacedDigit())
                                    .accessibilityIdentifier("totalAmount")
                            }
                        }
                        Section("Expenses") {
                            ForEach(shown) { expense in
                                ExpenseRow(expense: expense)
                                    .swipeActions {
                                        Button("Delete", role: .destructive) {
                                            store.delete(expense)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .searchable(text: $query.searchText, prompt: ExpenseListQuery.searchPrompt)
            .keepsToolbarVisibleWhileSearching()
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Sort", selection: $query.sortOrder) {
                            ForEach(ExpenseSortOrder.allCases) { order in
                                Text(order.title).tag(order)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                    .accessibilityIdentifier("sortMenu")
                }
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

private extension View {
    /// Keeps the Sort menu and Add button reachable while the search field is active.
    @ViewBuilder
    func keepsToolbarVisibleWhileSearching() -> some View {
        if #available(iOS 17.1, *) {
            searchPresentationToolbarBehavior(.avoidHidingContent)
        } else {
            self
        }
    }
}

#Preview {
    ExpenseListView()
        .environment(ExpenseStore())
}
