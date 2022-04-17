//
//  Daily_Fat_CounterApp.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-03-27.
//

import SwiftUI

@main
struct DailyFatCounterApp: App {
    @StateObject private var counterData = CounterData()
    @StateObject private var dailyData = DailyFatStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(counterData)
                .environmentObject(dailyData)
                .onAppear {
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
        }
    }
}
