import WidgetKit

struct QuickAddEntry: TimelineEntry {
    let date: Date
    let snapshot: SharedDataStore.Snapshot?
}

struct QuickAddTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickAddEntry {
        QuickAddEntry(
            date: .now,
            snapshot: SharedDataStore.Snapshot(todayTotal: 12.5, weekTotal: 64, weekBudget: 150, isOverBudget: false, updatedAt: .now)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickAddEntry) -> Void) {
        completion(QuickAddEntry(date: .now, snapshot: SharedDataStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickAddEntry>) -> Void) {
        let entry = QuickAddEntry(date: .now, snapshot: SharedDataStore.load())
        // No hace falta que el propio widget se refresque solo cada X minutos: la app
        // llama a WidgetCenter.shared.reloadAllTimelines() cada vez que cambian los
        // datos (ver NotificationManager.refreshDailySummaryNotification), así que con
        // una única entrada "para siempre" vale.
        completion(Timeline(entries: [entry], policy: .never))
    }
}
