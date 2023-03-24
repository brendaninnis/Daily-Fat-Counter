//
//  Daily_Fat_Counter_Widget.swift
//  Daily Fat Counter Widget
//
//  Created by Brendan Innis on 2023-03-03.
//

import SwiftUI
import WidgetKit

/// Provides data to Daily Fat Counter widgets and invokes resets according to the timeline.
struct DailyFatTimelineProvider {
    enum FetchEntryError: Error {
        case ioError(_ reason: String)
        case widgetFamilyNotSupported
    }

    typealias FetchEntryCompletion = (Result<FatCounterEntry, FetchEntryError>) -> Void
    typealias FetchTimelineCompletion = (Result<Timeline<FatCounterEntry>, FetchEntryError>) -> Void

    private func fetchEntry(for context: Context, _ completion: @escaping FetchEntryCompletion) {
        let counterData = CounterData()

        switch context.family {
        case .systemSmall:
            let entry = FatCounterEntry(date: Date(),
                                        usedGrams: counterData.usedFat,
                                        totalGrams: counterData.totalFat)
            completion(.success(entry))
        case .systemMedium:
            DailyFatStore.load { result in
                switch result {
                case let .success(history):
                    let entry = FatCounterEntry(date: Date(),
                                                usedGrams: counterData.usedFat,
                                                totalGrams: counterData.totalFat,
                                                recentHistory: Array(history.prefix(4)))
                    completion(.success(entry))
                case let .failure(failure):
                    completion(.failure(FetchEntryError.ioError(failure.localizedDescription)))
                }
            }
        default:
            completion(.failure(FetchEntryError.widgetFamilyNotSupported))
        }
    }

    private func fetchTimeline(_ completion: @escaping FetchTimelineCompletion) {
        let dailyData = DailyFatStore()
        let counterData = CounterData()

        DailyFatStore.load { result in
            switch result {
            case let .success(history):
                dailyData.history = history
                let entry = FatCounterEntry(date: Date(),
                                            usedGrams: counterData.usedFat,
                                            totalGrams: counterData.totalFat,
                                            recentHistory: Array(dailyData.history.prefix(4)))
                let nextResetDate = Date(timeIntervalSince1970: counterData.nextReset)
                counterData.start(withDelegate: dailyData)
                let timeline = Timeline(entries: [entry], policy: .after(nextResetDate))
                completion(.success(timeline))
            case let .failure(failure):
                completion(.failure(FetchEntryError.ioError(failure.localizedDescription)))
            }
        }
    }
}

// MARK: - TimelineProvider

extension DailyFatTimelineProvider: TimelineProvider {
    func placeholder(in _: Context) -> FatCounterEntry {
        DebugLog.log("TimelineProvider providing placeholder")
        return FatCounterEntry(date: Date(), usedGrams: 0, totalGrams: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (FatCounterEntry) -> Void) {
        DebugLog.log("TimelineProvider providing snapshot in context \(context)")
        fetchEntry(for: context) { result in
            switch result {
            case let .failure(error):
                DebugLog.log("Failed to load TimelineProvider entry \(error)")
                completion(placeholder(in: context))
            case let .success(entry):
                completion(entry)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        DebugLog.log("TimelineProvider providing timeline in context \(context)")
        fetchTimeline { result in
            switch result {
            case let .failure(error):
                DebugLog.log("Failed to load TimelineProvider timeline \(error)")
                completion(Timeline(entries: [placeholder(in: context)], policy: .never))
            case let .success(timeline):
                completion(timeline)
            }
        }
    }
}

// MARK: - Data model

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

// MARK: - Widget SwiftUI Views

struct DailyFatCounterWidgetView: View {
    static let circleSize: Double = 116

    @Environment(\.widgetFamily) var family: WidgetFamily

    var entry: DailyFatTimelineProvider.Entry

    @ViewBuilder
    var body: some View {
        switch family {
        case .accessoryInline, .accessoryCircular, .accessoryRectangular:
            CounterView(usedGrams: entry.usedGrams, totalGrams: entry.totalGrams)
                .frame(width: 52, height: 52)
        case .systemSmall:
            CounterView(usedGrams: entry.usedGrams, totalGrams: entry.totalGrams)
                .frame(width: Self.circleSize, height: Self.circleSize)
        case .systemMedium:
            DailyFatCounterMediumWidget(usedGrams: entry.usedGrams, totalGrams: entry.totalGrams, history: entry.recentHistory)
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
            CounterView(usedGrams: usedGrams, totalGrams: totalGrams)
                .frame(width: DailyFatCounterWidgetView.circleSize, height: DailyFatCounterWidgetView.circleSize)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 0))
            VStack(alignment: .leading, spacing: 4) {
                Text("Recent history")
                    .font(.subheadline)
                    .bold()
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

// MARK: - Widget

struct DailyFatCounterWidget: Widget {
    let kind: String = "Daily_Fat_Counter_Widget"
    
    var supportedFamilies: [WidgetFamily] {
        #if os(watchOS)
        return [.accessoryCircular, .accessoryRectangular, .accessoryInline]
        #else
        if #available(iOSApplicationExtension 16.0, *) {
            return [.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline]
        } else {
            return [.systemSmall, .systemMedium]
        }
        #endif
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyFatTimelineProvider()) { entry in
            DailyFatCounterWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's goal")
        .description("Check your dietary fat against your daily goal.")
        .supportedFamilies(supportedFamilies)
    }
}

// MARK: - Previews

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
        if #available(iOSApplicationExtension 16.0, *) {
            DailyFatCounterWidgetView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            DailyFatCounterWidgetView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            DailyFatCounterWidgetView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
        }
    }
}
