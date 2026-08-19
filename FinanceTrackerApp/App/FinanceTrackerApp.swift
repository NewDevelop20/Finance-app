import SwiftUI
import SwiftData

@main
struct FinanceTrackerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appState = AppState.shared

    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: ExpenseEntry.self, BudgetSettings.self)
        } catch {
            fatalError("No se pudo crear el ModelContainer de SwiftData: \(error)")
        }
        BackgroundTaskManager.register(container: container)
        NotificationManager.requestAuthorizationIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onOpenURL { url in
                    // Disparado por el widget de pantalla de bloqueo en tamaño "inline"
                    // (financetracker://quickadd), que no admite botones interactivos.
                    if url.host == "quickadd" {
                        appState.requestQuickAdd()
                    }
                }
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                let context = ModelContext(container)
                NotificationManager.refreshDailySummaryNotification(context: context)
            case .background:
                BackgroundTaskManager.scheduleNextRefresh()
            default:
                break
            }
        }
    }
}
