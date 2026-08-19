import Foundation
import UserNotifications
import SwiftData

/// Programa y refresca la notificación diaria de resumen ("cuánto llevas gastado hoy
/// y en la semana"). Como el contenido depende de datos que cambian a lo largo del día,
/// la volvemos a calcular y reprogramar cada vez que:
///   1. Se añade/edita/borra un movimiento.
///   2. La app pasa a primer plano.
///   3. Se ejecuta la tarea en segundo plano (ver `BackgroundTaskManager`).
///
/// Nota de fiabilidad: iOS no garantiza que una tarea en segundo plano se ejecute a una
/// hora exacta. Si el usuario no abre la app en todo el día, la notificación de las 23:00
/// puede llevar los datos de la última vez que se recalculó. Abrir la app aunque sea un
/// momento durante el día (o dejar activado "Actualización en segundo plano" para esta
/// app en Ajustes) mejora la puntualidad.
enum NotificationManager {
    static let dailySummaryIdentifier = "com.financetracker.dailySummary"

    static func requestAuthorizationIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        }
    }

    @MainActor
    static func refreshDailySummaryNotification(context: ModelContext) {
        let settings = BudgetSettings.fetchOrCreate(in: context)
        guard settings.notificationsEnabled else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailySummaryIdentifier])
            return
        }

        let allEntries = (try? context.fetch(FetchDescriptor<ExpenseEntry>())) ?? []
        let summary = BudgetCalculator.summary(all: allEntries, settings: settings)

        let content = UNMutableNotificationContent()
        content.title = "Resumen del día"
        content.body = summary.notificationBody
        content.sound = .default

        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        let now = Date()
        var comps = calendar.dateComponents([.year, .month, .day], from: now)
        comps.hour = settings.notificationHour
        comps.minute = settings.notificationMinute
        var fireDate = calendar.date(from: comps) ?? now

        // Si la hora de hoy ya pasó, programa para mañana con los mismos datos
        // (se recalculará de nuevo mañana en cuanto la app se abra o corra en segundo plano).
        if fireDate <= now {
            fireDate = calendar.date(byAdding: .day, value: 1, to: fireDate) ?? fireDate
        }

        let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(identifier: dailySummaryIdentifier, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailySummaryIdentifier])
        center.add(request)
    }
}
