import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExpenseEntry.date, order: .reverse) private var allEntries: [ExpenseEntry]

    @State private var filterType: EntryType?
    @State private var filterMethod: PaymentMethod?
    @State private var entryBeingEdited: ExpenseEntry?

    private var filteredEntries: [ExpenseEntry] {
        allEntries.filter { entry in
            (filterType == nil || entry.type == filterType) &&
            (filterMethod == nil || entry.paymentMethod == filterMethod)
        }
    }

    private var groupedByDay: [(day: Date, entries: [ExpenseEntry])] {
        let grouped = Dictionary(grouping: filteredEntries) { BudgetCalculator.startOfDay(for: $0.date) }
        return grouped.map { (day: $0.key, entries: $0.value) }.sorted { $0.day > $1.day }
    }

    var body: some View {
        NavigationStack {
            List {
                filtersSection
                ForEach(groupedByDay, id: \.day) { group in
                    Section(header: Text(dayLabel(group.day))) {
                        ForEach(group.entries) { entry in
                            EntryRow(entry: entry)
                                .contentShape(Rectangle())
                                .onTapGesture { entryBeingEdited = entry }
                        }
                        .onDelete { offsets in
                            delete(entries: group.entries, at: offsets)
                        }
                    }
                }
            }
            .navigationTitle("Historial")
            .overlay {
                if filteredEntries.isEmpty {
                    ContentUnavailableView(
                        "Sin movimientos",
                        systemImage: "tray",
                        description: Text("No hay nada que coincida con este filtro.")
                    )
                }
            }
            .sheet(item: $entryBeingEdited) { entry in
                AddExpenseSheet(entryToEdit: entry)
            }
        }
    }

    private var filtersSection: some View {
        Section {
            Picker("Tipo", selection: $filterType) {
                Text("Todos los tipos").tag(EntryType?.none)
                ForEach(EntryType.allCases) { type in
                    Text(type.label).tag(EntryType?.some(type))
                }
            }
            Picker("Método", selection: $filterMethod) {
                Text("Todos los métodos").tag(PaymentMethod?.none)
                ForEach(PaymentMethod.allCases) { method in
                    Text(method.label).tag(PaymentMethod?.some(method))
                }
            }
        }
    }

    private func delete(entries: [ExpenseEntry], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
        try? modelContext.save()
        NotificationManager.refreshDailySummaryNotification(context: modelContext)
    }

    private func dayLabel(_ day: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM"
        formatter.locale = Locale(identifier: "es_ES")
        let text = formatter.string(from: day)
        return text.prefix(1).uppercased() + text.dropFirst()
    }
}
