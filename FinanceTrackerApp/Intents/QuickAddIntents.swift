import AppIntents

/// Abre la app directamente sobre el menú de "añadir gasto", sin pedir ningún dato.
/// Pensado para colgarlo del botón de Acción, de un gesto Back Tap, de Siri, o de un
/// botón interactivo en el widget de pantalla de bloqueo: un solo toque/gesto y tienes
/// el formulario delante, listo para rellenar en 5 segundos.
///
/// Este archivo NO debe depender de SwiftData ni de ningún otro modelo: se comparte
/// tal cual con el target del widget (ver README, sección del widget de pantalla de
/// bloqueo), que no enlaza el resto de la app.
struct OpenQuickAddIntent: AppIntent {
    static var title: LocalizedStringResource = "Añadir gasto rápido"
    static var description = IntentDescription("Abre FinanceTracker directamente sobre el formulario de añadir movimiento.")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppState.shared.requestQuickAdd()
        return .result()
    }
}

/// Variante para cuando pagas en efectivo: abre el mismo menú pero con "Efectivo"
/// como método de pago ya preseleccionado.
struct OpenQuickAddCashIntent: AppIntent {
    static var title: LocalizedStringResource = "Añadir gasto en efectivo"
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppState.shared.requestQuickAdd(type: .gasto)
        return .result()
    }
}
