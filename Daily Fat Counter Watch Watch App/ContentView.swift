//
//  ContentView.swift
//  Daily Fat Counter Watch Watch App
//
//  Created by Brendan Innis on 2023-03-24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var counterData: CounterData
    @EnvironmentObject var dailyData: DailyFatStore
    @State private var selection: Tab = .counter

    enum Tab {
        case counter
        case history
        case settings
    }

    var body: some View {
        TabView(selection: $selection) {
            InteractiveCounter(
                usedGrams: $counterData.usedFat,
                totalGrams: $counterData.totalFat
            )
            .tag(Tab.counter)

            HistoryHome(history: $dailyData.history)
                .clipped()
                .tag(Tab.history)

            CounterSettings()
                .tag(Tab.settings)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
