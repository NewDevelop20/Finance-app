import Foundation

/// Puente de datos entre la app y el widget de pantalla de bloqueo, vía App Group.
/// No depende de SwiftData ni de ningún otro tipo del target principal a propósito:
/// este archivo se comparte tal cual con el target del widget (ver README).
enum SharedDataStore {
    /// Debes crear este App Group en tu cuenta de Apple Developer (Certificates,
    /// Identifiers & Profiles → Identifiers → App Groups) y usar el mismo identificador
    /// aquí, en las Capabilities del target de la app y en las del target del widget.
    /// Ver README, sección "Widget de pantalla de bloqueo".
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
