import Foundation

/// Puente de datos entre la app y el widget de pantalla de bloqueo, vía App Group.
/// No depende de SwiftData ni de ningún otro tipo del target principal a propósito:
/// este archivo se comparte tal cual con el target del widget (ver README).
///
/// Con firma gratuita (Personal Team, AltStore/SideStore) esto no hace nada útil a
/// propósito: `project.yml` no declara la capacidad "App Groups" porque las cuentas
/// gratuitas de Apple no la admiten, así que `UserDefaults(suiteName:)` no consigue
/// abrir un contenedor compartido real y `save`/`load` se convierten en no-ops
/// silenciosos (sin crashear). El widget ya está preparado para ese caso — ver
/// `Widgets/QuickAddWidget.swift`, que omite el total en vez de enseñar "0,00 €".
/// Si más adelante tienes cuenta de Apple Developer Program, añade la capacidad
/// App Groups en `project.yml` (ver comentarios ahí) y esto empieza a funcionar solo.
enum SharedDataStore {
    static let appGroupID = "group.com.tunombre.financetracker"

    private static let summaryKey = "dailySummarySnapshot"

    struct Snapshot: Codable {
        var todayTotal: Double
        var weekTotal: Double
        var weekBudget: Double
        var isOverBudget: Bool
        var updatedAt: Date
    }

    static func save(todayTotal: Double, weekTotal: Double, weekBudget: Double, isOverBudget: Bool) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        let snapshot = Snapshot(
            todayTotal: todayTotal,
            weekTotal: weekTotal,
            weekBudget: weekBudget,
            isOverBudget: isOverBudget,
            updatedAt: .now
        )
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: summaryKey)
    }

    static func load() -> Snapshot? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: summaryKey),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data)
        else { return nil }
        return snapshot
    }
}
