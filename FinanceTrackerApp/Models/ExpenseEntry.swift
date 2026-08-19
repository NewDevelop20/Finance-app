import Foundation
import SwiftData

@Model
final class ExpenseEntry {
    var id: UUID
    var date: Date
    var amount: Double
    var paymentMethodRaw: String
    var categoryRaw: String
    var typeRaw: String
    var note: String
    var createdAt: Date

    init(
        date: Date = .now,
        amount: Double,
        paymentMethod: PaymentMethod,
        category: ExpenseCategory,
        type: EntryType,
        note: String = ""
    ) {
        self.id = UUID()
        self.date = date
        self.amount = amount
        self.paymentMethodRaw = paymentMethod.rawValue
        self.categoryRaw = category.rawValue
        self.typeRaw = type.rawValue
        self.note = note
        self.createdAt = .now
    }

    var paymentMethod: PaymentMethod {
        get { PaymentMethod(rawValue: paymentMethodRaw) ?? .tarjeta }
        set { paymentMethodRaw = newValue.rawValue }
    }

    var category: ExpenseCategory {
        get { ExpenseCategory(rawValue: categoryRaw) ?? .otros }
        set { categoryRaw = newValue.rawValue }
    }

    var type: EntryType {
        get { EntryType(rawValue: typeRaw) ?? .gasto }
        set { typeRaw = newValue.rawValue }
    }

    /// Importe con signo tal y como cuenta contra el presupuesto de gasto:
    /// un gasto normal suma, un reembolso resta, ahorro/inversión no cuentan (0).
    var signedBudgetImpact: Double {
        switch type {
        case .gasto: return amount
        case .reembolso: return -amount
        case .ahorro, .inversion: return 0
        }
    }
}
