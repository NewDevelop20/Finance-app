import SwiftUI

struct BudgetProgressView: View {
    let summary: DailySummary

    private var progress: Double {
        guard summary.weekBudget > 0 else { return 0 }
        return min(summary.weekTotal / summary.weekBudget, 1)
    }

    private var barColor: Color {
        if summary.isOverBudget { return .red }
        if progress > 0.85 { return .orange }
        return .green
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Semana (lun–dom)")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(dateRangeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.2))
                    Capsule()
                        .fill(barColor)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 10)

            HStack {
                Text(currency(summary.weekTotal) + " de " + currency(summary.weekBudget))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if summary.isOverBudget {
                    Text("Te pasaste " + currency(abs(summary.weekRemaining)))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                } else {
                    Text("Quedan " + currency(summary.weekRemaining))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                }
            }
        }
    }

    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "es_ES")
        return "\(formatter.string(from: summary.weekStart)) – \(formatter.string(from: summary.weekEnd))"
    }

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: NSNumber(value: value)) ?? "\(value) €"
    }
}
