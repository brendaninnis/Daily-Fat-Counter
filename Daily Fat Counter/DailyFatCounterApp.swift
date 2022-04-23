//
//  Daily_Fat_CounterApp.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-03-27.
//

import SwiftUI

@main
struct DailyFatCounterApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject private var counterData = CounterData()
    @StateObject private var dailyData = DailyFatStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(counterData)
                .environmentObject(dailyData)
                .onAppear {
                    DebugLog.log("ContentView did appear")
                    DailyFatStore.load { result in
                        switch result {
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                        case .success(let history):
                            dailyData.history = history
                        }
                        counterData.start(withDelegate: dailyData)
                    }
                }
                .onChange(of: scenePhase) { newPhase in
                    if (newPhase == .active) {
                        DebugLog.log("App did become active")
                        counterData.initializeDailyFatReset(Int(Date().timeIntervalSince1970))
                    }
                }
        }
    }
}
