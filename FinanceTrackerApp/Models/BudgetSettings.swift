import Foundation
import SwiftData

/// Ajustes de presupuesto y notificación. Se espera una única instancia en el store
/// (ver `BudgetSettings.fetchOrCreate`).
@Model
final class BudgetSettings {
    var weeklyBudget: Double
    var monthlyBudget: Double
    var notificationHour: Int
    var notificationMinute: Int
    var notificationsEnabled: Bool

    init(
        weeklyBudget: Double = 150,
        monthlyBudget: Double = 600,
        notificationHour: Int = 23,
        notificationMinute: Int = 0,
        notificationsEnabled: Bool = true
    ) {
        self.weeklyBudget = weeklyBudget
        self.monthlyBudget = monthlyBudget
        self.notificationHour = notificationHour
        self.notificationMinute = notificationMinute
        self.notificationsEnabled = notificationsEnabled
    }
}

extension BudgetSettings {
    /// Devuelve el único `BudgetSettings` del store, creándolo si no existe todavía.
    @MainActor
    static func fetchOrCreate(in context: ModelContext) -> BudgetSettings {
        let descriptor = FetchDescriptor<BudgetSettings>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let created = BudgetSettings()
        context.insert(created)
        try? context.save()
        return created
    }
}
