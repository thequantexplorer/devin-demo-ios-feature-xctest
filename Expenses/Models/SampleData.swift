import Foundation

enum SampleData {
    /// Fixed sample expenses so the app and its tests always start from the same state.
    static let expenses: [Expense] = [
        Expense(id: id(1), title: "Groceries", amount: usd("64.20"), category: .food, date: day(2026, 10, 28)),
        Expense(id: id(2), title: "Coffee beans", amount: usd("18.50"), category: .food, date: day(2026, 10, 30)),
        Expense(id: id(3), title: "Train pass", amount: usd("92.00"), category: .transport, date: day(2026, 10, 1)),
        Expense(id: id(4), title: "Taxi to airport", amount: usd("41.75"), category: .transport, date: day(2026, 10, 22)),
        Expense(id: id(5), title: "Electricity bill", amount: usd("120.40"), category: .home, date: day(2026, 10, 15)),
        Expense(id: id(6), title: "Desk lamp", amount: usd("35.99"), category: .home, date: day(2026, 10, 9)),
        Expense(id: id(7), title: "Concert tickets", amount: usd("150.00"), category: .fun, date: day(2026, 10, 18)),
        Expense(id: id(8), title: "Movie night", amount: usd("24.00"), category: .fun, date: day(2026, 10, 30)),
        Expense(id: id(9), title: "Pharmacy", amount: usd("18.50"), category: .health, date: day(2026, 10, 12)),
        Expense(id: id(10), title: "Team lunch", amount: usd("56.30"), category: .work, date: day(2026, 10, 25)),
    ]

    /// Decimal from a string, so 18.50 is exactly 18.50 (a Double literal is not).
    static func usd(_ text: String) -> Decimal {
        Decimal(string: text, locale: Locale(identifier: "en_US"))!
    }

    private static func id(_ n: Int) -> UUID {
        UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", n))!
    }

    /// Noon UTC, so the calendar day is the same in every time zone between UTC-11 and UTC+11.
    static func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }
}
