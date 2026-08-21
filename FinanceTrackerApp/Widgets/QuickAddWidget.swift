import WidgetKit
import SwiftUI
import AppIntents

/// Widget de pantalla de bloqueo para el acceso rápido: un toque abre FinanceTracker
/// directamente sobre el formulario de "añadir gasto" (mismo mecanismo que el botón
/// de Acción o Back Tap — ver README, no hay forma de detectar el pago en sí).
struct QuickAddWidget: Widget {
    static let kind = "com.financetracker.quickadd"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: QuickAddTimelineProvider()) { entry in
            QuickAddWidgetView(entry: entry)
        }
        .configurationDisplayName("Añadir gasto")
        .description("Acceso rápido para apuntar un gasto.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct QuickAddWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: QuickAddEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            Button(intent: OpenQuickAddIntent()) {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
            }
            .buttonStyle(.plain)

        case .accessoryRectangular:
            Button(intent: OpenQuickAddIntent()) {
                VStack(alignment: .leading, spacing: 2) {
                    // `entry.snapshot` solo llega a tener datos si el App Group está
                    // activo (cuenta de pago, ver README sección 7). Sin él, se omite
                    // la línea del total en vez de enseñar un "0,00 €" engañoso.
                    if let total = entry.snapshot?.todayTotal {
                        Text("Hoy: \(currency(total))")
                            .font(.headline)
                            .lineLimit(1)
                    } else {
                        Text("FinanceTracker")
                            .font(.headline)
                            .lineLimit(1)
                    }
                    Label("Añadir gasto", systemImage: "plus.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

        case .accessoryInline:
            // Este tamaño no admite botones interactivos: el toque abre la app vía
            // widgetURL, y FinanceTrackerApp.onOpenURL abre el formulario al vuelo.
            if let total = entry.snapshot?.todayTotal {
                Text("Hoy \(currency(total)) · Toca para añadir")
                    .widgetURL(URL(string: "financetracker://quickadd"))
            } else {
                Text("Toca para añadir un gasto")
                    .widgetURL(URL(string: "financetracker://quickadd"))
            }

        default:
            EmptyView()
        }
    }

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_ES")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value)) €"
    }
}
