
import Foundation
import SwiftUI
import Combine

final class CounterData: ObservableObject {
    private var timer: Timer? = nil
    private var delegate: CounterDataDelegate?
    private var started = false
    
    @AppStorage("last_check") var lastCheck: Int = 0
    @AppStorage("reset_time") var resetTime: Int = 0 {
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
    @AppStorage("total_fat") var totalFat: Double = 45.0 {
        willSet {
            // Publish changes
            objectWillChange.send()
        }
    }
    @Published var dateForResetSelection: Date = Date() {
        didSet {
            let inttime = Int(dateForResetSelection.timeIntervalSince1970)
            resetTime = (inttime + TimeZone.current.secondsFromGMT()) % SECONDS_PER_DAY
            startResetTimer(Int(Date().timeIntervalSince1970))
        }
    }
    
    func start(withDelegate delegate: CounterDataDelegate? = nil) {
        started = true
        DebugLog.log("CounterData started at \(Date())")
        self.delegate = delegate
        initializeDailyFatReset(Int(Date().timeIntervalSince1970))
    }
    
    func initializeDailyFatReset(_ timestampInSeconds: Int) {
        guard started else {
            DebugLog.log("CounterData not started -- don't initialize daily fat reset")
            return
        }
        if (resetTimeElapsed(timestampInSeconds)) {
            DebugLog.log("Reset time elapsed")
            resetUsedFat()
        } else {
            lastCheck = timestampInSeconds
        }
        initializDateForResetSelection(timestampInSeconds)
    }
    
    private func resetTimeElapsed(_ timestampInSeconds: Int) -> Bool {
        guard lastCheck > 0 else {
            return false
        }
        let nowDays = (timestampInSeconds + TimeZone.current.secondsFromGMT() - resetTime) / SECONDS_PER_DAY
        let thenDays = (lastCheck + TimeZone.current.secondsFromGMT() - resetTime) / SECONDS_PER_DAY
        DebugLog.log("nowDays=\(nowDays) thendays=\(thenDays) now=\(timestampInSeconds) then=\(lastCheck)")
        return nowDays > thenDays
    }
    
    private func startResetTimer(_ timestampInSeconds: Int) {
        let nowOffset = timestampInSeconds + TimeZone.current.secondsFromGMT()
        let nowSinceMidnight = nowOffset % SECONDS_PER_DAY
        let fireAt: Int;
        if (nowSinceMidnight < resetTime) {
            fireAt = resetTime - nowSinceMidnight
        } else {
            fireAt = SECONDS_PER_DAY - nowSinceMidnight + resetTime
        }
        DebugLog.log("Start reset timer fireAt: \(Date(timeIntervalSinceNow: TimeInterval(fireAt)))")
        timer?.invalidate()
        timer = Timer(fireAt: Date(timeIntervalSinceNow: TimeInterval(fireAt)), interval: TimeInterval(SECONDS_PER_DAY), target: self, selector: #selector(self.resetUsedFat), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func initializDateForResetSelection(_ timestampInSeconds: Int) {
        let lastMidnight = timestampInSeconds - (timestampInSeconds % SECONDS_PER_DAY)
        dateForResetSelection = Date(
            timeIntervalSince1970: TimeInterval(
                lastMidnight + resetTime - TimeZone.current.secondsFromGMT()
            )
        )
    }
    
    @objc private func resetUsedFat() {
        DebugLog.log("Reset daily fat")
        createDailyFat()
        usedFat = 0
        lastCheck = Int(Date().timeIntervalSince1970)
    }
    
    private func createDailyFat() {
        let nowOffset = lastCheck + TimeZone.current.secondsFromGMT()
        let nowSinceMidnight = nowOffset % SECONDS_PER_DAY
        let dateComponents: DateComponents
        if (nowSinceMidnight >= resetTime) {
            dateComponents = Calendar.current.dateComponents(
                [.day, .month, .year], from: Date(timeIntervalSince1970: Double(lastCheck)))
            // Last reset today
        } else {
            dateComponents = Calendar.current.dateComponents(
                [.day, .month, .year], from: Date(timeIntervalSince1970: Double(lastCheck - SECONDS_PER_DAY)))
            // Last reset yesterday
        }
        DebugLog.log("Create DailyFat for year=\(dateComponents.year!) month=\(dateComponents.month!) day=\(dateComponents.day!)")
        delegate?.newDailyFat(DailyFat.createDailyFat(
            year: dateComponents.year!,
            month: dateComponents.month!,
            day: dateComponents.day!,
            usedFat: usedFat,
            totalFat: totalFat
        ))
    }

}

protocol CounterDataDelegate {
    func newDailyFat(_ dailyFat: DailyFat)
}
