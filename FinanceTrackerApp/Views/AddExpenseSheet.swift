import SwiftUI
import SwiftData

/// El menú de alta rápida. Se abre igual desde el botón "+" de la app, desde el
/// botón de Acción/Back Tap (vía `OpenQuickAddIntent`) o desde un Atajo de Siri.
struct AddExpenseSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// Movimiento a editar; nil cuando es un alta nueva.
    var entryToEdit: ExpenseEntry?
    var initialType: EntryType?

    @State private var type: EntryType = .gasto
    @State private var amountText: String = ""
    @State private var paymentMethod: PaymentMethod = .tarjeta
    @State private var category: ExpenseCategory = .comestibles
    @State private var note: String = ""
    @State private var date: Date = .now
    @FocusState private var amountFieldFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Tipo", selection: $type) {
                        ForEach(EntryType.allCases) { entryType in
                            Label(entryType.label, systemImage: entryType.symbol).tag(entryType)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Importe") {
                    HStack {
                        Text("€")
                            .foregroundStyle(.secondary)
                        TextField("0,00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .font(.title2.weight(.semibold))
                            .focused($amountFieldFocused)
                    }
                }

                if type == .gasto || type == .reembolso {
                    Section("Categoría") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 84), spacing: 10)], spacing: 10) {
                            ForEach(ExpenseCategory.allCases) { cat in
                                CategoryChip(category: cat, isSelected: category == cat) {
                                    category = cat
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Método") {
                    Picker("Método de pago", selection: $paymentMethod) {
                        ForEach(PaymentMethod.allCases) { method in
                            Label(method.label, systemImage: method.symbol).tag(method)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    DatePicker("Fecha y hora", selection: $date)
                    TextField("Nota (opcional)", text: $note)
                }
            }
            .navigationTitle(entryToEdit == nil ? "Nuevo movimiento" : "Editar movimiento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(parsedAmount == nil || parsedAmount == 0)
                }
            }
            .onAppear(perform: setUpInitialState)
        }
    }

    private var parsedAmount: Double? {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    private func setUpInitialState() {
        if let entry = entryToEdit {
            type = entry.type
            amountText = String(format: "%.2f", entry.amount).replacingOccurrences(of: ".", with: ",")
            paymentMethod = entry.paymentMethod
            category = entry.category
            note = entry.note
            date = entry.date
        } else {
            if let initialType {
                type = initialType
            }
            amountFieldFocused = true
        }
    }

    private func save() {
        guard let amount = parsedAmount, amount > 0 else { return }

        if let entry = entryToEdit {
            entry.amount = amount
            entry.paymentMethod = paymentMethod
            entry.category = category
            entry.type = type
            entry.note = note
            entry.date = date
        } else {
            let entry = ExpenseEntry(
                date: date,
                amount: amount,
                paymentMethod: paymentMethod,
                category: category,
                type: type,
                note: note
            )
            modelContext.insert(entry)
        }

        try? modelContext.save()
        NotificationManager.refreshDailySummaryNotification(context: modelContext)
        dismiss()
    }
}

private struct CategoryChip: View {
    let category: ExpenseCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: category.symbol)
                    .font(.title3)
                Text(category.label)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.08))
            .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
