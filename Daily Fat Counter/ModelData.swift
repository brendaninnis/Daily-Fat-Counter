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
    var timer: Timer? = nil
    
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
    
    init() {
        // Reset daily fat
        let now = Int(Date().timeIntervalSince1970) - resetTime
        if (resetTimeElapsed(now)) {
            resetUsedFat()
        }
        let nowSinceMidnight = now % SECONDS_PER_DAY
        let fireAt: Int;
        if (nowSinceMidnight < resetTime) {
            fireAt = resetTime - nowSinceMidnight
        } else {
            fireAt = SECONDS_PER_DAY - nowSinceMidnight + resetTime
        }
        timer = Timer(fireAt: Date(timeIntervalSinceNow: TimeInterval(fireAt)), interval: TimeInterval(SECONDS_PER_DAY), target: self, selector: #selector(self.resetUsedFat), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    @objc private func resetUsedFat() {
        usedFat = 0
    }
    
    private func resetTimeElapsed(_ timestampInSeconds: Int) -> Bool {
        let nowDays = timestampInSeconds / SECONDS_PER_DAY
        let thenDays = (Int(lastLaunch) - resetTime)  / SECONDS_PER_DAY
        return nowDays > thenDays
    }
}
