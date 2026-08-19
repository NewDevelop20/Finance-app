import Foundation
import AppIntents
import SwiftUI

/// Cómo se pagó el movimiento.
enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
    case tarjeta
    case efectivo
    case bizum
    case transferencia

    var id: String { rawValue }

    var label: String {
        switch self {
        case .tarjeta: return "Tarjeta"
        case .efectivo: return "Efectivo"
        case .bizum: return "Bizum"
        case .transferencia: return "Transferencia"
        }
    }

    var symbol: String {
        switch self {
        case .tarjeta: return "creditcard.fill"
        case .efectivo: return "banknote.fill"
        case .bizum: return "bolt.horizontal.circle.fill"
        case .transferencia: return "arrow.left.arrow.right.circle.fill"
        }
    }
}

/// Tipo de movimiento: qué representa el dinero, no en qué se gastó.
enum EntryType: String, Codable, CaseIterable, Identifiable {
    case gasto
    case ahorro
    case inversion
    case reembolso

    var id: String { rawValue }

    var label: String {
        switch self {
        case .gasto: return "Gasto"
        case .ahorro: return "Ahorro"
        case .inversion: return "Inversión"
        case .reembolso: return "Reembolso"
        }
    }

    var symbol: String {
        switch self {
        case .gasto: return "arrow.down.circle.fill"
        case .ahorro: return "banknote.fill"
        case .inversion: return "chart.line.uptrend.xyaxis.circle.fill"
        case .reembolso: return "arrow.uturn.left.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .gasto: return .red
        case .ahorro: return .green
        case .inversion: return .blue
        case .reembolso: return .teal
        }
    }

    /// Signo aplicado al importe cuando se calcula el gasto neto del día/semana.
    /// Ahorro e inversión no cuentan contra el presupuesto de gasto (se muestran aparte);
    /// un reembolso resta del gasto neto.
    var countsAgainstBudget: Bool {
        self == .gasto || self == .reembolso
    }
}

/// Categoría del gasto (solo aplica de forma habitual a `.gasto`, pero se guarda siempre
/// para poder filtrar reembolsos por la categoría a la que corresponden).
enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case comestibles
    case restaurantes
    case ropa
    case alquiler
    case gasolina
    case transporte
    case coche
    case seguros
    case salud
    case ocio
    case suscripciones
    case hogar
    case educacion
    case viajes
    case regalos
    case mascotas
    case otros

    var id: String { rawValue }

    var label: String {
        switch self {
        case .comestibles: return "Comestibles"
        case .restaurantes: return "Restaurantes"
        case .ropa: return "Ropa"
        case .alquiler: return "Alquiler"
        case .gasolina: return "Gasolina"
        case .transporte: return "Transporte"
        case .coche: return "Coche"
        case .seguros: return "Seguros"
        case .salud: return "Salud"
        case .ocio: return "Ocio"
        case .suscripciones: return "Suscripciones"
        case .hogar: return "Hogar"
        case .educacion: return "Educación"
        case .viajes: return "Viajes"
        case .regalos: return "Regalos"
        case .mascotas: return "Mascotas"
        case .otros: return "Otros"
        }
    }

    var symbol: String {
        switch self {
        case .comestibles: return "cart.fill"
        case .restaurantes: return "fork.knife"
        case .ropa: return "tshirt.fill"
        case .alquiler: return "house.fill"
        case .gasolina: return "fuelpump.fill"
        case .transporte: return "bus.fill"
        case .coche: return "car.fill"
        case .seguros: return "shield.lefthalf.filled"
        case .salud: return "cross.case.fill"
        case .ocio: return "gamecontroller.fill"
        case .suscripciones: return "repeat.circle.fill"
        case .hogar: return "hammer.fill"
        case .educacion: return "book.fill"
        case .viajes: return "airplane"
        case .regalos: return "gift.fill"
        case .mascotas: return "pawprint.fill"
        case .otros: return "ellipsis.circle.fill"
        }
    }
}

// MARK: - AppEnum: exponen estos tipos a Atajos/Siri para los App Intents.

enum PaymentMethodEntity: String, AppEnum {
    case tarjeta, efectivo, bizum, transferencia

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Método de pago"
    static var caseDisplayRepresentations: [PaymentMethodEntity: DisplayRepresentation] = [
        .tarjeta: "Tarjeta",
        .efectivo: "Efectivo",
        .bizum: "Bizum",
        .transferencia: "Transferencia"
    ]

    var model: PaymentMethod {
        PaymentMethod(rawValue: rawValue) ?? .tarjeta
    }
}

enum EntryTypeEntity: String, AppEnum {
    case gasto, ahorro, inversion, reembolso

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Tipo de movimiento"
    static var caseDisplayRepresentations: [EntryTypeEntity: DisplayRepresentation] = [
        .gasto: "Gasto",
        .ahorro: "Ahorro",
        .inversion: "Inversión",
        .reembolso: "Reembolso"
    ]

    var model: EntryType {
        EntryType(rawValue: rawValue) ?? .gasto
    }
}

enum ExpenseCategoryEntity: String, AppEnum {
    case comestibles, restaurantes, ropa, alquiler, gasolina, transporte, coche
    case seguros, salud, ocio, suscripciones, hogar, educacion, viajes, regalos, mascotas, otros

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Categoría"
    static var caseDisplayRepresentations: [ExpenseCategoryEntity: DisplayRepresentation] = [
        .comestibles: "Comestibles", .restaurantes: "Restaurantes", .ropa: "Ropa",
        .alquiler: "Alquiler", .gasolina: "Gasolina", .transporte: "Transporte",
        .coche: "Coche", .seguros: "Seguros", .salud: "Salud", .ocio: "Ocio",
        .suscripciones: "Suscripciones", .hogar: "Hogar", .educacion: "Educación",
        .viajes: "Viajes", .regalos: "Regalos", .mascotas: "Mascotas", .otros: "Otros"
    ]

    var model: ExpenseCategory {
        ExpenseCategory(rawValue: rawValue) ?? .otros
    }
}
