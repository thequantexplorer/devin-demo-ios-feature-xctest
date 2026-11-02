import Foundation

enum Category: String, CaseIterable, Identifiable {
    case food = "Food"
    case transport = "Transport"
    case home = "Home"
    case fun = "Fun"
    case health = "Health"
    case work = "Work"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "tram.fill"
        case .home: "house.fill"
        case .fun: "ticket.fill"
        case .health: "cross.case.fill"
        case .work: "briefcase.fill"
        }
    }
}

struct Expense: Identifiable, Hashable {
    let id: UUID
    var title: String
    var amount: Decimal
    var category: Category
    var date: Date

    init(id: UUID = UUID(), title: String, amount: Decimal, category: Category, date: Date) {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
    }
}

enum Money {
    static let locale = Locale(identifier: "en_US")

    static func format(_ amount: Decimal) -> String {
        amount.formatted(.currency(code: "USD").locale(locale))
    }

    /// Parses user input like "12.5" or "$1,200.00". Returns nil for anything else.
    static func parse(_ text: String) -> Decimal? {
        let cleaned = text
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        guard !cleaned.isEmpty, let value = Decimal(string: cleaned, locale: locale) else { return nil }
        return value
    }
}
