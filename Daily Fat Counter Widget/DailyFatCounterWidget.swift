//
//  Daily_Fat_Counter_Widget.swift
//  Daily Fat Counter Widget
//
//  Created by Brendan Innis on 2023-03-03.
//

import SwiftUI
import WidgetKit

/// Provides data to Daily Fat Counter widgets and invokes resets according to the timeline.
class DailyFatTimelineProvider: NSObject {
    enum FetchEntryError: Error {
        case ioError(_ reason: String)
        case widgetFamilyNotSupported
    }

    typealias FetchEntryCompletion = (Result<FatCounterEntry, FetchEntryError>) -> Void
    typealias DailyFatTimeline = Timeline<FatCounterEntry>
    typealias FetchTimelineCompletion = (Result<DailyFatTimeline, FetchEntryError>) -> Void

    private var _dailyData: DailyFatStore?
    private var dailyData: DailyFatStore {
        guard let _dailyData else {
            let _dailyData = DailyFatStore()
            self._dailyData = _dailyData
            return _dailyData
        }
        return _dailyData
    }

    private var _counterData: CounterData?
    private var counterData: CounterData {
        guard let _counterData else {
            let _counterData = CounterData()
            self._counterData = _counterData
            return _counterData
        }
        return _counterData
    }

    private var timelineCompletion: FetchTimelineCompletion?
    private var entryCompletion: FetchEntryCompletion?

    private var entry: FatCounterEntry {
        FatCounterEntry(date: Date(),
                        usedGrams: counterData.usedFat,
                        totalGrams: counterData.totalFat,
                        recentHistory: Array(dailyData.history.prefix(4)))
    }

    private var timeline: DailyFatTimeline {
        let nextResetDate = Date(timeIntervalSince1970: counterData.nextReset)
        return Timeline(entries: [entry], policy: .after(nextResetDate))
    }

    private func resetStoredData() {
        _dailyData = nil
        _counterData = nil
        timelineCompletion = nil
        entryCompletion = nil
    }

    private func fetchEntry(for _: Context, _ completion: @escaping FetchEntryCompletion) {
        entryCompletion = completion

        DailyFatStore.load { [weak self] result in
            guard let self else {
                return
            }
            switch result {
            case let .success(history):
                dailyData.history = history
                counterData.start(withDelegate: self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard let self else {
                        return
                    }
                    // Give 1 second to update and save a new daily fat entry, if there is one
                    entryCompletion?(.success(entry))
                    resetStoredData()
                }
            case let .failure(failure):
                completion(.failure(FetchEntryError.ioError(failure.localizedDescription)))
            }
        }
    }

    private func fetchTimeline(_ completion: @escaping FetchTimelineCompletion) {
        timelineCompletion = completion

        DailyFatStore.load { [weak self] result in
            guard let self else {
                return
            }
            switch result {
            case let .success(history):
                dailyData.history = history
                counterData.start(withDelegate: self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard let self else {
                        return
                    }
                    // Give 1 second to update and save a new daily fat entry, if there is one
                    timelineCompletion?(.success(timeline))
                    resetStoredData()
                }
            case let .failure(failure):
                completion(.failure(FetchEntryError.ioError(failure.localizedDescription)))
            }
        }
    }
}

extension DailyFatTimelineProvider: CounterDataDelegate {
    func historyDidUpdate() {
        // NOOP
    }

    func updateCompanion() {
        // NOOP
    }

    func newDailyFat(start: Double, usedFat: Double, totalFat: Double) {
        DebugLog.log("New daily fat log")
        dailyData.history.insert(DailyFat(id: dailyData.history.count,
                                          start: start,
                                          usedFat: usedFat,
                                          totalFat: totalFat),
                                 at: 0)
        DailyFatStore.save(history: dailyData.history) { [weak self] result in
            guard let self else {
                return
            }
            switch result {
            case let .success(count):
                DebugLog.log("Daily fat #\(count) saved.")
            case let .failure(error):
                DebugLog.log("Failed to save daily fat: \(error.localizedDescription)")
            }
            timelineCompletion?(.success(timeline))
            entryCompletion?(.success(entry))
            resetStoredData()
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
        fetchEntry(for: context) { [weak self] result in
            guard let self else {
                return
            }
            switch result {
            case let .failure(error):
                DebugLog.log("Failed to load TimelineProvider entry \(error)")
                completion(placeholder(in: context))
            case let .success(entry):
                DebugLog.log("Calling completion with entry \(entry)")
                completion(entry)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        DebugLog.log("TimelineProvider providing timeline in context \(context)")
        fetchTimeline { [weak self] result in
            guard let self else {
                return
            }
            switch result {
            case let .failure(error):
                DebugLog.log("Failed to load TimelineProvider timeline \(error)")
                completion(Timeline(entries: [placeholder(in: context)], policy: .never))
            case let .success(timeline):
                DebugLog.log("Calling completion with timeline \(timeline)")
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
            CounterView(usedGrams: entry.usedGrams,
                        totalGrams: entry.totalGrams,
                        useSmallFont: true)
                .frame(width: 52, height: 52)
        case .systemSmall:
            CounterView(usedGrams: entry.usedGrams,
                        totalGrams: entry.totalGrams)
                .frame(width: Self.circleSize, height: Self.circleSize)
        case .systemMedium:
            DailyFatCounterMediumWidget(usedGrams: entry.usedGrams,
                                        totalGrams: entry.totalGrams,
                                        history: entry.recentHistory)
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
