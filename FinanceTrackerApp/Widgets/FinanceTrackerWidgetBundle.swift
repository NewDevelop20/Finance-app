import WidgetKit
import SwiftUI

/// Punto de entrada del target de extensión de widget. Xcode genera uno de estos al
/// crear el target "Widget Extension"; sustituye el que te ponga por defecto por este.
@main
struct FinanceTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        QuickAddWidget()
    }
}
