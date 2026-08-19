import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query(sort: \ExpenseEntry.date, order: .reverse) private var allEntries: [ExpenseEntry]

    private enum Period: String, CaseIterable, Identifiable {
        case week = "Semana"
        case month = "Mes"
        var id: String { rawValue }
    }

    @State private var period: Period = .week

    private var entriesInPeriod: [ExpenseEntry] {
        switch period {
        case .week: return BudgetCalculator.entries(inWeekOf: .now, from: allEntries)
        case .month: return BudgetCalculator.entries(inMonthOf: .now, from: allEntries)
        }
    }

    private var byCategory: [(category: ExpenseCategory, total: Double)] {
        BudgetCalculator.totalByCategory(entriesInPeriod)
    }

    private var totalGasto: Double { BudgetCalculator.total(entriesInPeriod, type: .gasto) }
    private var totalAhorro: Double { BudgetCalculator.total(entriesInPeriod, type: .ahorro) }
    private var totalInversion: Double { BudgetCalculator.total(entriesInPeriod, type: .inversion) }
    private var totalReembolso: Double { BudgetCalculator.total(entriesInPeriod, type: .reembolso) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Picker("Periodo", selection: $period) {
                        ForEach(Period.allCases) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)

                    summaryCards

                    if byCategory.isEmpty {
                        ContentUnavailableView(
                            "Sin datos todavía",
                            systemImage: "chart.pie",
                            description: Text("Añade algún gasto para ver el desglose por categoría.")
                        )
                        .frame(height: 260)
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Gasto por categoría")
                                .font(.headline)
                            Chart(byCategory, id: \.category) { item in
                                BarMark(
                                    x: .value("Total", item.total),
                                    y: .value("Categoría", item.category.label)
                                )
                                .foregroundStyle(by: .value("Categoría", item.category.label))
                            }
                            .frame(height: CGFloat(byCategory.count) * 34 + 20)
                        }
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    }
                }
                .padding()
            }
            .navigationTitle("Estadísticas")
        }
    }

    private var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(title: "Gastado", value: totalGasto, color: .red, symbol: EntryType.gasto.symbol)
            statCard(title: "Ahorrado", value: totalAhorro, color: .green, symbol: EntryType.ahorro.symbol)
            statCard(title: "Invertido", value: totalInversion, color: .blue, symbol: EntryType.inversion.symbol)
            statCard(title: "Reembolsado", value: totalReembolso, color: .teal, symbol: EntryType.reembolso.symbol)
        }
    }

    private func statCard(title: String, value: Double, color: Color, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: symbol)
                .font(.caption)
                .foregroundStyle(color)
            Text(currency(value))
                .font(.title3.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: NSNumber(value: value)) ?? "\(value) €"
    }
}
