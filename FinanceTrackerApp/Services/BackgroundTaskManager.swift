import Foundation
import BackgroundTasks
import SwiftData

/// Intento "best effort" de refrescar el resumen diario poco antes de la hora configurada,
/// aunque el usuario no haya abierto la app. iOS decide cuándo (y si) ejecuta esto
/// realmente; no hay garantía de puntualidad exacta, solo mejora las probabilidades.
enum BackgroundTaskManager {
    static let refreshTaskIdentifier = "com.financetracker.refreshSummary"

    static func register(container: ModelContainer) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshTaskIdentifier, using: nil) { task in
            handle(task: task as! BGAppRefreshTask, container: container)
        }
    }

    static func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskIdentifier)
        // Pide ejecutarse dentro de la próxima hora; el sistema lo ajustará según uso real de la app.
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }

    private static func handle(task: BGAppRefreshTask, container: ModelContainer) {
        scheduleNextRefresh()

        let context = ModelContext(container)
        Task { @MainActor in
            NotificationManager.refreshDailySummaryNotification(context: context)
            task.setTaskCompleted(success: true)
        }

        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
    }
}
