//
//  ModelData.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-04-03.
//

import Foundation
import SwiftUI
import Combine

final class ModelData: ObservableObject {
    private var timer: Timer? = nil
    
    @AppStorage("last_launch") var lastLaunch: Double = 0.0
    @AppStorage("reset_time") var resetTime: Int = 6600 {
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
    
    init() {
        let now = Date().timeIntervalSince1970
        let intnow = Int(now)
        intializeDailyFatReset(intnow)
        initializDateForResetSelection(intnow)
        lastLaunch = now
        
    }
    
    private func intializeDailyFatReset(_ timestampInSeconds: Int) {
        if (resetTimeElapsed(timestampInSeconds)) {
            resetUsedFat()
        }
    }
    
    private func resetTimeElapsed(_ timestampInSeconds: Int) -> Bool {
        let nowDays = timestampInSeconds / SECONDS_PER_DAY
        let thenDays = (Int(lastLaunch) - resetTime)  / SECONDS_PER_DAY
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
        usedFat = 0
    }

}
