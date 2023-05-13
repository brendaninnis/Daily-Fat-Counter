
import Combine
import Foundation
import SwiftUI
import WatchConnectivity
import WidgetKit

final class CounterData: NSObject, ObservableObject {
    enum StorageKeys {
        static let nextReset = "next_reset"
        static let resetHour = "reset_hour"
        static let resetMinute = "reset_minute"
        static let usedFat = "used_fat"
        static let totalFat = "total_fat"
        static let isFirstRun = "is_first_run"
    }

    static let defaults = UserDefaults(suiteName: APP_GROUP_IDENTIFIER)

    private weak var delegate: CounterDataDelegate?

    private var timer: Timer?
    private var started = false
    private var companionUsedFatUpdateTask: Task<Void, Never>?
    private var calendar: Calendar { .autoupdatingCurrent }
    private var wcSession: WCSession { .default }
    private var wcSessionUserInfoTransfer: WCSessionUserInfoTransfer?

    @AppStorage(StorageKeys.nextReset, store: defaults) var nextReset: TimeInterval = 0.0 {
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
            if oldValue != nextReset {
                updateWCUserInfo()
            }
        }
    }

    @AppStorage(StorageKeys.resetHour, store: defaults) var resetHour: Int = 0 {
        willSet {
            // Publish changes
            objectWillChange.send()
        }
    }

    @AppStorage(StorageKeys.resetMinute, store: defaults) var resetMinute: Int = 0 {
        willSet {
            // Publish changes
            objectWillChange.send()
        }
    }

    @AppStorage(StorageKeys.usedFat, store: defaults) var usedFat: Double = 0.0 {
        willSet {
            // Publish changes
            objectWillChange.send()
        }
        didSet {
            let didUpdate = oldValue != usedFat
            companionUsedFatUpdateTask?.cancel()
            companionUsedFatUpdateTask = Task { @MainActor in
                // Delay for 500 milliseconds to wait for the user to end inputs
                do {
                    try await Task.sleep(nanoseconds: UInt64(5e8))
                } catch {
                    DebugLog.log("Widget refresh task cancelled")
                    return
                }
                if #available(watchOS 9.0, *) {
                    DebugLog.log("Reload widget timelines")
                    WidgetCenter.shared.reloadAllTimelines()
                }
                if didUpdate {
                    updateWCUserInfo()
                }
            }
        }
    }

    @AppStorage(StorageKeys.totalFat, store: defaults) var totalFat: Double = 50.0 {
        willSet {
            // Publish changes
            objectWillChange.send()
        }
        didSet {
            if oldValue != totalFat {
                updateWCUserInfo()
            }
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
            wcSession.delegate = self
            wcSession.activate()
        }
    }

    func start(withDelegate delegate: CounterDataDelegate? = nil) {
        started = true
        DebugLog.log("CounterData started at \(Date())")
        self.delegate = delegate
        initializeDailyFatReset(Date().timeIntervalSince1970)
        if let defaults = Self.defaults, !defaults.bool(forKey: StorageKeys.isFirstRun) {
            // Ensure Watch apps are provided context when it is their first time running
            updateWCUserInfo()
            delegate?.updateCompanion()
        }
        Self.defaults?.set(true, forKey: StorageKeys.isFirstRun)
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

    private func updateWCUserInfo() {
        if let wcSessionUserInfoTransfer, wcSessionUserInfoTransfer.isTransferring {
            // The previous update has not finished it's transfer yet, so cancel it and send a new update
            wcSessionUserInfoTransfer.cancel()
        }
        wcSessionUserInfoTransfer = wcSession.transferUserInfo([
            StorageKeys.nextReset: nextReset,
            StorageKeys.resetHour: resetHour,
            StorageKeys.resetMinute: resetMinute,
            StorageKeys.usedFat: usedFat,
            StorageKeys.totalFat: totalFat,
        ])
    }
}

extension CounterData: WCSessionDelegate {
    func session(_: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DebugLog.log("WCSession activation complete with state: \(activationState), error: \(error?.localizedDescription ?? "")")
    }

    #if os(iOS)
        func sessionDidBecomeInactive(_: WCSession) {
            DebugLog.log("WCSession did become inactive")
        }

        func sessionDidDeactivate(_ session: WCSession) {
            DebugLog.log("WCSession did deactivate")
            session.activate()
        }
    #endif

    func session(_: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        DispatchQueue.main.async {
            if let resetHour = userInfo[StorageKeys.resetHour] as? Int {
                self.resetHour = resetHour
            }
            if let resetMinute = userInfo[StorageKeys.resetMinute] as? Int {
                self.resetMinute = resetMinute
            }
            if let usedFat = userInfo[StorageKeys.usedFat] as? Double {
                self.usedFat = usedFat
            }
            if let totalFat = userInfo[StorageKeys.totalFat] as? Double {
                self.totalFat = totalFat
            }
            if let nextReset = userInfo[StorageKeys.nextReset] as? TimeInterval {
                self.nextReset = nextReset
            }
        }
    }

    func session(_: WCSession, didReceive file: WCSessionFile) {
        guard let fileUrl = try? DailyFatStore.fileURL() else {
            DebugLog.log("Failed to construct store file URL")
            return
        }
        do {
            try FileManager.default.moveItem(at: file.fileURL, to: fileUrl)
        } catch {
            DebugLog.log("Failed to move file to store URL")
            return
        }
        DispatchQueue.main.async {
            self.delegate?.historyDidUpdate()
        }
    }
}

protocol CounterDataDelegate: AnyObject {
    func newDailyFat(start: Double, usedFat: Double, totalFat: Double)
    func historyDidUpdate()
    func updateCompanion()
}
