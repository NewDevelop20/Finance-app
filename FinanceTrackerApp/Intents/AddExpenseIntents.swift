import AppIntents
import SwiftData
import Foundation

/// Abre la app directamente sobre el menú de "añadir gasto", sin pedir ningún dato.
/// Este es el intent pensado para asignar al botón de Acción o a un gesto de Back Tap
/// (Ajustes > Accesibilidad > Tocar la parte trasera > elige un Atajo que ejecute esto):
/// un solo toque/gesto y tienes el formulario delante, listo para rellenar en 5 segundos.
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

/// Registra el movimiento sin abrir ninguna pantalla — pensado para decirlo por voz:
/// "Oye Siri, añade 12 euros de comestibles con tarjeta".
struct LogExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Registrar gasto por voz"
    static var description = IntentDescription("Registra un movimiento directamente, sin abrir la app.")

    @Parameter(title: "Importe")
    var amount: Double

    @Parameter(title: "Categoría")
    var category: ExpenseCategoryEntity

    @Parameter(title: "Método de pago", default: .tarjeta)
    var method: PaymentMethodEntity

    @Parameter(title: "Tipo", default: .gasto)
    var type: EntryTypeEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Añadir \(\.$amount) € de \(\.$category) con \(\.$method)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(for: ExpenseEntry.self, BudgetSettings.self)
        let context = ModelContext(container)

        let entry = ExpenseEntry(
            amount: amount,
            paymentMethod: method.model,
            category: category.model,
            type: type.model
        )
        context.insert(entry)
        try context.save()

        NotificationManager.refreshDailySummaryNotification(context: context)

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_ES")
        let amountText = formatter.string(from: NSNumber(value: amount)) ?? "\(amount) €"
        return .result(dialog: "Apuntado: \(amountText) en \(category.model.label).")
    }
}

struct FinanceTrackerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenQuickAddIntent(),
            phrases: [
                "Añade un gasto en \(.applicationName)",
                "Abre \(.applicationName) para añadir un gasto"
            ],
            shortTitle: "Añadir gasto",
            systemImageName: "plus.circle.fill"
        )
        AppShortcut(
            intent: OpenQuickAddCashIntent(),
            phrases: [
                "Añade un gasto en efectivo en \(.applicationName)"
            ],
            shortTitle: "Gasto en efectivo",
            systemImageName: "banknote.fill"
        )
        AppShortcut(
            intent: LogExpenseIntent(),
            phrases: [
                "Registra un gasto en \(.applicationName)"
            ],
            shortTitle: "Registrar gasto por voz",
            systemImageName: "mic.fill"
        )
    }
}
