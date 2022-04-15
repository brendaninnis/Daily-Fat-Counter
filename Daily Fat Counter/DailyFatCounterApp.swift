//
//  Daily_Fat_CounterApp.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-03-27.
//

import SwiftUI

@main
struct DailyFatCounterApp: App {
    @StateObject private var modelData = ModelData()
    @StateObject private var dailyData = DailyFatStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
                .environmentObject(dailyData)
                .onAppear {
                    DailyFatStore.load { result in
                        switch result {
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                        case .success(let history):
                            dailyData.history = history
                        }
                    }
            }
        }
    }
}
