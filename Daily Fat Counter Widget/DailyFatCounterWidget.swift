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
    
    // MARK: Data fields
    private let counterData = CounterData()
    private let dailyData = DailyFatStore()
    
    // MARK: Convenience vars
    private var usedFat: Double {
        counterData.usedFat
    }
    private var totalFat: Double {
        counterData.totalFat
    }
    private var nextReset: TimeInterval {
        counterData.nextReset
    }
    
    enum FetchEntryError: Error {
        case ioError(_ reason: String)
        case widgetFamilyNotSupported
    }
    
    typealias FetchEntryCompletion = ((Result<FatCounterEntry, FetchEntryError>) -> Void)
    
    private func fetchEntry(for context: Context, _ completion: @escaping FetchEntryCompletion) {
        switch (context.family) {
        case .systemSmall:
            let entry = FatCounterEntry(date: Date(), usedGrams: usedFat, totalGrams: totalFat)
            completion(.success(entry))
        case .systemMedium:
            DailyFatStore.load { result in
                switch result {
                case .success(let history):
                    let entry = FatCounterEntry(date: Date(),
                                                usedGrams: usedFat,
                                                totalGrams: totalFat,
                                                recentHistory: Array(history.prefix(4)))
                    completion(.success(entry))
                case .failure(let failure):
                    completion(.failure(FetchEntryError.ioError(failure.localizedDescription)))
                }
            }
        default:
            completion(.failure(FetchEntryError.widgetFamilyNotSupported))
        }
    }
     
    private func loadHistoryAndStartCounter(_ completion: @escaping () -> Void) {
        DailyFatStore.load { result in
            switch result {
            case .success(let history):
                dailyData.history = history
            case .failure(let failure):
                fatalError(failure.localizedDescription)
            }
            counterData.start(withDelegate: dailyData)
            completion()
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
            case .failure(let error):
                DebugLog.log("Failed to load TimelineProvider entry \(error)")
                completion(placeholder(in: context))
            case .success(let entry):
                completion(entry)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        DebugLog.log("TimelineProvider providing timeline in context \(context)")
        loadHistoryAndStartCounter {
            let entry = FatCounterEntry(date: Date(),
                                        usedGrams: usedFat,
                                        totalGrams: totalFat,
                                        recentHistory: Array(dailyData.history.prefix(4)))
            let nextResetDate = Date(timeIntervalSince1970: nextReset)
            completion(Timeline(entries: [entry], policy: .after(nextResetDate)))
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
        case .systemSmall:
            CounterView(circleSize: Self.circleSize, usedGrams: entry.usedGrams, totalGrams: entry.totalGrams)
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
            CounterView(circleSize: DailyFatCounterWidgetView.circleSize,
                        usedGrams: usedGrams,
                        totalGrams: totalGrams)
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

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyFatTimelineProvider()) { entry in
            DailyFatCounterWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's goal")
        .description("Check your dietary fat against your daily goal.")
        .supportedFamilies([.systemSmall, .systemMedium])
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
    }
}
