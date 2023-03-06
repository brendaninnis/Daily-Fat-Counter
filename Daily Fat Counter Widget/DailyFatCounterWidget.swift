//
//  Daily_Fat_Counter_Widget.swift
//  Daily Fat Counter Widget
//
//  Created by Brendan Innis on 2023-03-03.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    static let defaults = UserDefaults(suiteName: "group.ca.brendaninnis.dailyfatcounter")

    @AppStorage("used_fat", store: Self.defaults) var usedFat: Double = 0.0
    @AppStorage("total_fat", store: Self.defaults) var totalFat: Double = 50.0

    func placeholder(in _: Context) -> FatCounterEntry {
        FatCounterEntry(date: Date(), usedGrams: 0, totalGrams: 0)
    }

    func getSnapshot(in _: Context, completion: @escaping (FatCounterEntry) -> Void) {
        let entry = FatCounterEntry(date: Date(), usedGrams: usedFat, totalGrams: totalFat)
        completion(entry)
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = FatCounterEntry(date: Date(), usedGrams: usedFat, totalGrams: totalFat)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct FatCounterEntry: TimelineEntry {
    let date: Date
    let usedGrams: Double
    let totalGrams: Double
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
            DailyFatCounterMediumWidget(usedGrams: entry.usedGrams, totalGrams: entry.totalGrams)
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
    let history: [DailyFat] = [
        DailyFat(id: 0,
                 start: 1_654_637_866,
                 usedFat: 35,
                 totalFat: 45),
        DailyFat(id: 0,
                 start: 1_654_637_866,
                 usedFat: 35,
                 totalFat: 45),
        DailyFat(id: 0,
                 start: 1_654_637_866,
                 usedFat: 35,
                 totalFat: 45),
        DailyFat(id: 0,
                 start: 1_654_637_866,
                 usedFat: 35,
                 totalFat: 45),
    ]
    
    var body: some View {
        HStack {
            CounterView(circleSize: DailyFatCounterWidgetView.circleSize,
                        usedGrams: usedGrams,
                        totalGrams: totalGrams)
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 0))
            VStack(alignment: .leading, spacing: 4) {
                Text("Recent history")
                    .font(.subheadline)
                if history.isEmpty {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("A history of your daily fat consumtion will be displayed here once a day has passed.")
                            .multilineTextAlignment(.center)
                            .font(.headline)
                        Spacer()
                    }
                    Spacer()
                } else {
                    ForEach(history, id: \.id) { dailyFat in
                        HistoryRow(dailyFat: history.first!, useShortDate: true, isAnimated: .constant(true))
                    }
                    Spacer()
                }
            }.padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
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
        DailyFatCounterWidgetView(entry: FatCounterEntry(date: Date(), usedGrams: 28.0, totalGrams: 45.0))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        DailyFatCounterWidgetView(entry: FatCounterEntry(date: Date(), usedGrams: 28.0, totalGrams: 45.0))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
