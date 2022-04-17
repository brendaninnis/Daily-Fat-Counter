//
//  ContentView.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-03-27.
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
            CounterHome()
                .tabItem {
                    Label("Counter", systemImage: "timer")
                }
                .tag(Tab.counter)
            
            HistoryHome(history: $dailyData.history)
                .clipped()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
                .tag(Tab.history)

            CounterSettings()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CounterData())
            .environmentObject(DailyFatStore())
    }
}
