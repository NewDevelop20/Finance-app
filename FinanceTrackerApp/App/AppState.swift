import Foundation
import Combine

/// Enrutador compartido entre la app y los App Intents (Atajos/Siri/Botón de Acción).
/// Cuando se dispara un intent, guarda la petición aquí; la vista raíz observa este
/// objeto y presenta el mismo menú de "añadir gasto" tanto si lo abres a mano desde
/// la app como si lo lanzas con un gesto.
@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    /// Tipo de movimiento preseleccionado al abrir el menú rápido (nil = elegir dentro).
    @Published var pendingQuickAddType: EntryType?
    @Published var showQuickAdd: Bool = false

    private init() {}

    func requestQuickAdd(type: EntryType? = nil) {
        pendingQuickAddType = type
        showQuickAdd = true
    }
}
