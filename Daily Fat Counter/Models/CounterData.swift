
import Combine
import Foundation
import SwiftUI
import WatchConnectivity

final class CounterData: NSObject, ObservableObject {
    static let defaults = UserDefaults(suiteName: APP_GROUP_IDENTIFIER)

    private var timer: Timer?
    private var started = false
    private weak var delegate: CounterDataDelegate?
    private var calendar: Calendar {
        Calendar.autoupdatingCurrent
    }

    @AppStorage("next_reset", store: defaults) var nextReset: TimeInterval = 0.0 {
        willSet {
            // Publish changes
            objectWillChange.send()
        }
        @available(iOSApplicationExtension, unavailable)
        didSet {
            if dateForResetSelection.timeIntervalSince1970 != nextReset {
                dateForResetSelection = Date(timeIntervalSince1970: nextReset)
            }
            startResetTimer()
        }
    }

    @AppStorage("reset_hour", store: defaults) var resetHour: Int = 0 {
        willSet {
            // Publish changes
            objectWillChange.send()
        }
    }

    @AppStorage("reset_minute", store: defaults) var resetMinute: Int = 0 {
        willSet {
            // Publish changes
            objectWillChange.send()
        }
    }

    @AppStorage("used_fat", store: defaults) var usedFat: Double = 0.0 {
        willSet {
            // Publish changes
            objectWillChange.send()
        }
    }

    @AppStorage("total_fat", store: defaults) var totalFat: Double = 50.0 {
        willSet {
            // Publish changes
            objectWillChange.send()
        }
    }

    @Published var dateForResetSelection: Date = .init() {
        didSet {
            let dateComponents = calendar.dateComponents([.hour, .minute], from: dateForResetSelection)
            resetHour = dateComponents.hour!
            resetMinute = dateComponents.minute!
            if dateForResetSelection.timeIntervalSince1970 != nextReset {
                nextReset = dateForResetSelection.timeIntervalSince1970
            }
        }
    }
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
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
        if timestamp >= nextReset && nextReset > 0 {
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
                                               direction: .backward)
        else {
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
                      matchingPolicy: .nextTimePreservingSmallerComponents)?.timeIntervalSince1970
        else {
            DebugLog.log("Failed to find next reset")
            return timestamp + Double(SECONDS_PER_DAY)
        }
        return result
    }
}

extension CounterData: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DebugLog.log("WCSession activation complete with state: \(activationState), error: \(error?.localizedDescription ?? "")")
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        DebugLog.log("WCSession did become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        DebugLog.log("WCSession did deactivate")
        session.activate()
    }
    #endif
}

protocol CounterDataDelegate: AnyObject {
    func newDailyFat(start: Double, usedFat: Double, totalFat: Double)
}
