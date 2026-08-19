import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [BudgetSettings]

    private var settings: BudgetSettings {
        BudgetSettings.fetchOrCreate(in: modelContext)
    }

    @State private var weeklyBudgetText: String = ""
    @State private var monthlyBudgetText: String = ""
    @State private var notificationTime: Date = Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? .now
    @State private var notificationsEnabled: Bool = true
    @State private var notificationPermissionDenied = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Presupuesto") {
                    HStack {
                        Text("Semanal (lun–dom)")
                        Spacer()
                        TextField("€", text: $weeklyBudgetText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    HStack {
                        Text("Mensual")
                        Spacer()
                        TextField("€", text: $monthlyBudgetText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }

                Section("Aviso de las noches") {
                    Toggle("Resumen diario", isOn: $notificationsEnabled)
                    if notificationsEnabled {
                        DatePicker("Hora", selection: $notificationTime, displayedComponents: .hourAndMinute)
                    }
                    if notificationPermissionDenied {
                        Label("Activa las notificaciones para FinanceTracker en Ajustes del iPhone.", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }

                Section("Acceso rápido con gestos") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("La app expone dos Atajos: **Añadir gasto rápido** y **Registrar gasto por voz**. Dos formas recomendadas de dispararlos justo después de pagar:")
                            .font(.footnote)
                        Label("Botón de Acción (iPhone 15 Pro o superior): Ajustes → Botón de Acción → Atajo → Añadir gasto rápido.", systemImage: "button.programmable")
                            .font(.footnote)
                        Label("Back Tap: Ajustes → Accesibilidad → Tocar la parte trasera → Doble/Triple toque → Atajo → Añadir gasto rápido.", systemImage: "iphone.gen3.radiowaves.left.and.right")
                            .font(.footnote)
                        Label("Siri: “Oye Siri, registra un gasto en FinanceTracker”.", systemImage: "mic.fill")
                            .font(.footnote)
                    }
                    .foregroundStyle(.secondary)
                }

                Section {
                    Text("Apple no permite que ninguna app detecte automáticamente un pago con tarjeta o Apple Pay. Por eso el acceso rápido es un gesto tuyo (botón/Back Tap/Siri) que abre el mismo formulario al instante, en vez de una detección automática.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Ajustes")
            .onAppear(perform: loadFromSettings)
            .onChange(of: weeklyBudgetText) { _, _ in persist() }
            .onChange(of: monthlyBudgetText) { _, _ in persist() }
            .onChange(of: notificationTime) { _, _ in persist() }
            .onChange(of: notificationsEnabled) { _, enabled in
                persist()
                if enabled { checkNotificationPermission() }
            }
        }
    }

    private func loadFromSettings() {
        let s = settings
        weeklyBudgetText = String(format: "%.2f", s.weeklyBudget).replacingOccurrences(of: ".", with: ",")
        monthlyBudgetText = String(format: "%.2f", s.monthlyBudget).replacingOccurrences(of: ".", with: ",")
        notificationsEnabled = s.notificationsEnabled
        var comps = DateComponents()
        comps.hour = s.notificationHour
        comps.minute = s.notificationMinute
        notificationTime = Calendar.current.date(from: comps) ?? .now
        checkNotificationPermission()
    }

    private func persist() {
        let s = settings
        s.weeklyBudget = Double(weeklyBudgetText.replacingOccurrences(of: ",", with: ".")) ?? s.weeklyBudget
        s.monthlyBudget = Double(monthlyBudgetText.replacingOccurrences(of: ",", with: ".")) ?? s.monthlyBudget
        s.notificationsEnabled = notificationsEnabled
        let comps = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        s.notificationHour = comps.hour ?? 23
        s.notificationMinute = comps.minute ?? 0
        try? modelContext.save()
        NotificationManager.refreshDailySummaryNotification(context: modelContext)
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationPermissionDenied = settings.authorizationStatus == .denied
            }
        }
    }
}
