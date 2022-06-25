
import Foundation
import SwiftUI
import Combine

final class CounterData: ObservableObject {
    private var timer: Timer? = nil
    private var started = false
    private weak var delegate: CounterDataDelegate?
    private var calendar: Calendar {
        Calendar.autoupdatingCurrent
    }
    
    @AppStorage("next_reset") var nextReset: TimeInterval = 0.0 {
        willSet {
            // Publish changes
            objectWillChange.send()
        }
        didSet {
            if (dateForResetSelection.timeIntervalSince1970 != nextReset) {
                dateForResetSelection = Date(timeIntervalSince1970: nextReset)
            }
            startResetTimer()
        }
    }
    @AppStorage("reset_hour") var resetHour: Int = 0 {
        willSet {
            // Publish changes
            objectWillChange.send()
        }
    }
    @AppStorage("reset_minute") var resetMinute: Int = 0 {
        willSet {
            // Publish changes
            objectWillChange.send()
        }
    }
    @AppStorage("used_fat") var usedFat: Double = 0.0 {
        willSet {
            // Publish changes
            objectWillChange.send()
        }
    }
    @AppStorage("total_fat") var totalFat: Double = 50.0 {
        willSet {
            // Publish changes
            objectWillChange.send()
        }
    }
    @Published var dateForResetSelection: Date = Date() {
        didSet {
            let dateComponents = calendar.dateComponents([.hour, .minute], from: dateForResetSelection)
            resetHour = dateComponents.hour!
            resetMinute = dateComponents.minute!
            if (dateForResetSelection.timeIntervalSince1970 != nextReset) {
                nextReset = dateForResetSelection.timeIntervalSince1970
            }
        }
    }
    
    func start(withDelegate delegate: CounterDataDelegate? = nil) {
        started = true
        DebugLog.log("CounterData started at \(Date())")
        self.delegate = delegate
        initializeDailyFatReset(Date().timeIntervalSince1970)
    }
    
    func initializeDailyFatReset(_ timestamp: TimeInterval) {
        guard started else {
            DebugLog.log("CounterData not started -- don't initialize daily fat reset")
            return
        }
        if (timestamp >= nextReset && nextReset > 0) {
            DebugLog.log("Reset time elapsed")
            resetUsedFat()
        } else {
            nextReset = calculateNextReset(timestamp)
        }
    }
    
    private func startResetTimer() {
        let fireAt = Date(timeIntervalSince1970: nextReset)
        DebugLog.log("Start reset timer fireAt: \(fireAt)")
        timer?.invalidate()
        timer = Timer(fire: fireAt, interval: 0, repeats: false, block: { [weak self] _ in
            self?.resetUsedFat()
            self?.startResetTimer()
        })
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    @objc private func resetUsedFat() {
        DebugLog.log("Reset daily fat")
        createDailyFat()
        usedFat = 0
        nextReset = calculateNextReset(Date().timeIntervalSince1970)
    }
    
    private func createDailyFat() {
        guard let lastDate = calendar.nextDate(after: Date(timeIntervalSince1970: nextReset),
                                               matching: DateComponents(hour: resetHour, minute: resetMinute),
                                               matchingPolicy: .nextTimePreservingSmallerComponents,
                                               direction: .backward) else {
            DebugLog.log("Failed to find previous reset")
            return
        }
        DebugLog.log("Create DailyFat for \(lastDate)")
        delegate?.newDailyFat(start: lastDate.timeIntervalSince1970, usedFat: usedFat, totalFat: totalFat)
    }
    
    private func calculateNextReset(_ timestamp: TimeInterval) -> TimeInterval {
        guard let result = calendar
            .nextDate(after: Date(timeIntervalSince1970: timestamp),
                      matching: DateComponents(hour: resetHour,
                                               minute: resetMinute),
                      matchingPolicy: .nextTimePreservingSmallerComponents)?.timeIntervalSince1970 else {
            DebugLog.log("Failed to find next reset")
            return timestamp + Double(SECONDS_PER_DAY)
        }
        return result
    }

}

protocol CounterDataDelegate: AnyObject {
    func newDailyFat(start: Double, usedFat: Double, totalFat: Double)
}
