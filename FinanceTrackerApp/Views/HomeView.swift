import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExpenseEntry.date, order: .reverse) private var allEntries: [ExpenseEntry]
    @Query private var settingsList: [BudgetSettings]

    private var settings: BudgetSettings {
        settingsList.first ?? BudgetSettings()
    }

    private var todayEntries: [ExpenseEntry] {
        BudgetCalculator.entries(on: .now, from: allEntries)
    }

    private var summary: DailySummary {
        BudgetCalculator.summary(all: allEntries, settings: settings)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 6) {
                        Text("Hoy has gastado")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(currency(summary.todayTotal))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))

                    BudgetProgressView(summary: summary)
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))

                    quickAddButtons

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Movimientos de hoy")
                            .font(.headline)
                        if todayEntries.isEmpty {
                            Text("Todavía no has apuntado nada hoy.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 24)
                        } else {
                            ForEach(todayEntries) { entry in
                                EntryRow(entry: entry)
                            }
                        }
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                }
                .padding()
            }
            .navigationTitle("Hoy")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        appState.requestQuickAdd()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
        }
    }

    private var quickAddButtons: some View {
        HStack(spacing: 12) {
            ForEach(EntryType.allCases) { type in
                Button {
                    appState.requestQuickAdd(type: type)
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: type.symbol)
                            .font(.title3)
                        Text(type.label)
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(type.tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(type.tint)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: NSNumber(value: value)) ?? "\(value) €"
    }
}
