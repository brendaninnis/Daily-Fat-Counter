//
//  Daily_Fat_Counter_Widget.swift
//  Daily Fat Counter Widget
//
//  Created by Brendan Innis on 2023-03-03.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    @AppStorage("used_fat") var usedFat: Double = 0.0
    @AppStorage("total_fat") var totalFat: Double = 50.0

    func placeholder(in _: Context) -> FatCounterEntry {
        FatCounterEntry(date: Date(), usedGrams: 28.0, totalGrams: 45.0)
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

struct Daily_Fat_Counter_WidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        CounterView(circleSize: 130, usedGrams: entry.usedGrams, totalGrams: entry.totalGrams)
    }
}

struct Daily_Fat_Counter_Widget: Widget {
    let kind: String = "Daily_Fat_Counter_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Daily_Fat_Counter_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today's goal")
        .description("Check your dietary fat against your daily goal.")
        .supportedFamilies([.systemSmall])
    }
}

struct Daily_Fat_Counter_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Daily_Fat_Counter_WidgetEntryView(entry: FatCounterEntry(date: Date(), usedGrams: 28.0, totalGrams: 45.0))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        Daily_Fat_Counter_WidgetEntryView(entry: FatCounterEntry(date: Date(), usedGrams: 28.0, totalGrams: 45.0))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .preferredColorScheme(.dark)
    }
}
