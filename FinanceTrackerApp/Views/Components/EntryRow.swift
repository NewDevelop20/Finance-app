import SwiftUI

struct EntryRow: View {
    let entry: ExpenseEntry

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(entry.type.tint.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: entry.type == .gasto ? entry.category.symbol : entry.type.symbol)
                    .foregroundStyle(entry.type.tint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.type == .gasto ? entry.category.label : entry.type.label)
                    .font(.subheadline.weight(.medium))
                HStack(spacing: 6) {
                    Image(systemName: entry.paymentMethod.symbol)
                        .font(.caption2)
                    Text(entry.paymentMethod.label)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(amountText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(entry.type == .reembolso ? .green : .primary)
                Text(timeText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var amountText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_ES")
        let sign = entry.type == .reembolso ? "+" : ""
        return sign + (formatter.string(from: NSNumber(value: entry.amount)) ?? "\(entry.amount) €")
    }

    private var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: entry.date)
    }
}
