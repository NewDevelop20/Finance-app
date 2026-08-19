import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Hoy", systemImage: "sun.max.fill") }

            HistoryView()
                .tabItem { Label("Historial", systemImage: "list.bullet") }

            StatsView()
                .tabItem { Label("Estadísticas", systemImage: "chart.pie.fill") }

            SettingsView()
                .tabItem { Label("Ajustes", systemImage: "gearshape.fill") }
        }
        .sheet(isPresented: $appState.showQuickAdd) {
            AddExpenseSheet(initialType: appState.pendingQuickAddType)
        }
        .onAppear {
            _ = BudgetSettings.fetchOrCreate(in: modelContext)
        }
    }
}
