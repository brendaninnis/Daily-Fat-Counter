
import SwiftUI
import WidgetKit

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
                        case let .failure(error):
                            fatalError(error.localizedDescription)
                        case let .success(history):
                            dailyData.history = history
                        }
                        counterData.start(withDelegate: dailyData)
                    }
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        DebugLog.log("App did become active")
                        counterData.initializeDailyFatReset(Date().timeIntervalSince1970)
                    } else if newPhase == .inactive {
                        DebugLog.log("App did become inactive")
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
        }
    }
}
