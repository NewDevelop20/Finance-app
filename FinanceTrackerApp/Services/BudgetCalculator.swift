import Foundation
import SwiftData

struct DailySummary {
    let todayTotal: Double
    let weekTotal: Double
    let weekBudget: Double
    let weekRemaining: Double
    let isOverBudget: Bool
    let weekStart: Date
    let weekEnd: Date

    /// Texto en español listo para meter en una notificación o en la UI.
    var notificationBody: String {
        let today = Self.money(todayTotal)
        let week = Self.money(weekTotal)
        let budget = Self.money(weekBudget)
        if isOverBudget {
            let over = Self.money(abs(weekRemaining))
            return "Hoy has gastado \(today). Esta semana llevas \(week) de \(budget) de presupuesto: te has pasado \(over)."
        } else {
            let remaining = Self.money(weekRemaining)
            return "Hoy has gastado \(today). Esta semana llevas \(week) de \(budget) de presupuesto: te quedan \(remaining) para el domingo."
        }
    }

    private static func money(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_ES")
        formatter.currencyCode = "EUR"
        return formatter.string(from: NSNumber(value: value)) ?? "\(value) €"
    }
}

/// Toda la lógica de "cuánto llevo gastado hoy/esta semana" vive aquí para que
/// la UI y el gestor de notificaciones compartan exactamente el mismo cálculo.
enum BudgetCalculator {
    /// Semana de lunes a domingo.
    private static var mondayFirstCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // lunes
        calendar.locale = Locale(identifier: "es_ES")
        return calendar
    }()

    static func startOfDay(for date: Date) -> Date {
        mondayFirstCalendar.startOfDay(for: date)
    }

    static func startOfWeek(for date: Date) -> Date {
        let components = mondayFirstCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return mondayFirstCalendar.date(from: components) ?? date
    }

    static func endOfWeek(for date: Date) -> Date {
        mondayFirstCalendar.date(byAdding: .day, value: 6, to: startOfWeek(for: date)) ?? date
    }

    static func entries(on day: Date, from all: [ExpenseEntry]) -> [ExpenseEntry] {
        let start = startOfDay(for: day)
        guard let end = mondayFirstCalendar.date(byAdding: .day, value: 1, to: start) else { return [] }
        return all.filter { $0.date >= start && $0.date < end }
    }

    static func entries(inWeekOf day: Date, from all: [ExpenseEntry]) -> [ExpenseEntry] {
        let start = startOfWeek(for: day)
        guard let end = mondayFirstCalendar.date(byAdding: .day, value: 7, to: start) else { return [] }
        return all.filter { $0.date >= start && $0.date < end }
    }

    static func entries(inMonthOf day: Date, from all: [ExpenseEntry]) -> [ExpenseEntry] {
        let start = mondayFirstCalendar.date(from: mondayFirstCalendar.dateComponents([.year, .month], from: day)) ?? day
        guard let end = mondayFirstCalendar.date(byAdding: .month, value: 1, to: start) else { return [] }
        return all.filter { $0.date >= start && $0.date < end }
    }

    static func netBudgetTotal(_ entries: [ExpenseEntry]) -> Double {
        entries.reduce(0) { $0 + $1.signedBudgetImpact }
    }

    static func total(_ entries: [ExpenseEntry], type: EntryType) -> Double {
        entries.filter { $0.type == type }.reduce(0) { $0 + $1.amount }
    }

    static func summary(all: [ExpenseEntry], settings: BudgetSettings, reference: Date = .now) -> DailySummary {
        let today = netBudgetTotal(entries(on: reference, from: all))
        let week = netBudgetTotal(entries(inWeekOf: reference, from: all))
        let remaining = settings.weeklyBudget - week
        return DailySummary(
            todayTotal: today,
            weekTotal: week,
            weekBudget: settings.weeklyBudget,
            weekRemaining: remaining,
            isOverBudget: remaining < 0,
            weekStart: startOfWeek(for: reference),
            weekEnd: endOfWeek(for: reference)
        )
    }

    static func totalByCategory(_ entries: [ExpenseEntry]) -> [(category: ExpenseCategory, total: Double)] {
        let gastos = entries.filter { $0.type == .gasto }
        let grouped = Dictionary(grouping: gastos, by: \.category)
        return grouped.map { (category: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }
}
