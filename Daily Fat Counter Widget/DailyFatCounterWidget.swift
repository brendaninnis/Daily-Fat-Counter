//
//  Daily_Fat_Counter_Widget.swift
//  Daily Fat Counter Widget
//
//  Created by Brendan Innis on 2023-03-03.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    static let defaults = UserDefaults(suiteName: APP_GROUP_IDENTIFIER)

    @AppStorage("used_fat", store: Self.defaults) var usedFat: Double = 0.0
    @AppStorage("total_fat", store: Self.defaults) var totalFat: Double = 50.0

    func placeholder(in _: Context) -> FatCounterEntry {
        FatCounterEntry(date: Date(), usedGrams: 0, totalGrams: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (FatCounterEntry) -> Void) {
        switch (context.family) {
        case .systemSmall:
            let entry = FatCounterEntry(date: Date(), usedGrams: usedFat, totalGrams: totalFat)
            completion(entry)
        case .systemMedium, .systemLarge:
            DailyFatStore.load { result in
                switch result {
                case .success(let success):
                    let entry = FatCounterEntry(date: Date(),
                                                usedGrams: usedFat,
                                                totalGrams: totalFat,
                                                recentHistory: Array(success.prefix(4)))
                    completion(entry)
                case .failure(let failure):
                    DebugLog.log("Failed to load Daily Fat history \(failure.localizedDescription)")
                }
            }
        default:
            fatalError("Widget size not supported")
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        switch (context.family) {
        case .systemSmall:
            let entry = FatCounterEntry(date: Date(), usedGrams: usedFat, totalGrams: totalFat)
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
        case .systemMedium, .systemLarge:
            DailyFatStore.load { result in
                switch result {
                case .success(let success):
                    let entry = FatCounterEntry(date: Date(),
                                                usedGrams: usedFat,
                                                totalGrams: totalFat,
                                                recentHistory: Array(success.prefix(4)))
                    let timeline = Timeline(entries: [entry], policy: .never)
                    completion(timeline)
                case .failure(let failure):
                    DebugLog.log("Failed to load Daily Fat history \(failure.localizedDescription)")
                }
            }
        default:
            fatalError("Widget size not supported")
        }
    }
}

struct FatCounterEntry: TimelineEntry {
    let date: Date
    let usedGrams: Double
    let totalGrams: Double
    let recentHistory: [DailyFat]
    
    internal init(date: Date, usedGrams: Double, totalGrams: Double, recentHistory: [DailyFat] = []) {
        self.date = date
        self.usedGrams = usedGrams
        self.totalGrams = totalGrams
        self.recentHistory = recentHistory
    }
}

struct DailyFatCounterWidgetView: View {
    static let circleSize: Double = 116

    @Environment(\.widgetFamily) var family: WidgetFamily

    var entry: Provider.Entry

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            CounterView(circleSize: Self.circleSize, usedGrams: entry.usedGrams, totalGrams: entry.totalGrams)
        case .systemMedium:
            DailyFatCounterMediumWidget(usedGrams: entry.usedGrams, totalGrams: entry.totalGrams, history: entry.recentHistory)
        case .systemLarge:
            CounterView(circleSize: Self.circleSize, usedGrams: entry.usedGrams, totalGrams: entry.totalGrams)
        default:
            fatalError("Widget size not supported")
        }
    }
}

struct DailyFatCounterMediumWidget: View {
    let usedGrams: Double
    let totalGrams: Double
    let history: [DailyFat]
    
    var body: some View {
        HStack {
            CounterView(circleSize: DailyFatCounterWidgetView.circleSize,
                        usedGrams: usedGrams,
                        totalGrams: totalGrams)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 0))
            VStack(alignment: .leading, spacing: 4) {
                Text("Recent history")
                    .font(.subheadline)
                if history.isEmpty {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("No history yet.")
                            .multilineTextAlignment(.center)
                            .font(.headline)
                        Spacer()
                    }
                    Spacer()
                } else {
                    ForEach(history, id: \.id) { dailyFat in
                        HistoryRow(dailyFat: dailyFat, useShortDate: true, isAnimated: .constant(true))
                    }
                    Spacer()
                }
            }.padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 16))
        }
    }
}

struct DailyFatCounterWidget: Widget {
    let kind: String = "Daily_Fat_Counter_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyFatCounterWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's goal")
        .description("Check your dietary fat against your daily goal.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct DailyFatCounterWidgetPreviews: PreviewProvider {
    static var previews: some View {
        let entry = FatCounterEntry(date: Date(),
                                    usedGrams: 40.0,
                                    totalGrams: 45.0,
                                    recentHistory: [
                                        DailyFat(id: 3,
                                                 start: 1_654_865_401,
                                                 usedFat: 55,
                                                 totalFat: 45),
                                        DailyFat(id: 2,
                                                 start: 1_654_779_001,
                                                 usedFat: 100,
                                                 totalFat: 45),
                                        DailyFat(id: 1,
                                                 start: 1_654_692_601,
                                                 usedFat: 35,
                                                 totalFat: 45),
                                        DailyFat(id: 0,
                                                 start: 1_654_637_866,
                                                 usedFat: 42,
                                                 totalFat: 45),
                                    ])
        DailyFatCounterWidgetView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        DailyFatCounterWidgetView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
