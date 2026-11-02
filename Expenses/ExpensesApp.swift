import SwiftUI

@main
struct ExpensesApp: App {
    @State private var store = ExpenseStore()

    var body: some Scene {
        WindowGroup {
            ExpenseListView()
                .environment(store)
        }
    }
}
