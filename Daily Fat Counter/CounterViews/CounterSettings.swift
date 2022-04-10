//
//  CounterSettings.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-04-03.
//

import SwiftUI

struct CounterSettings: View {
    @EnvironmentObject var modelData: ModelData
    
    private var hours: Int {
        modelData.resetTime / SECONDS_PER_HOUR
    }
    private var minutes: Int {
        (modelData.resetTime % SECONDS_PER_HOUR) / SECONDS_PER_MINUTE
    }
    private var displayTime: String {
        let period: String;
        var hoursForDisplay = hours;
        if (hours > 12) {
            period = "p.m."
            hoursForDisplay = hours - 12;
        } else if (hours == 12) {
            period = "p.m."
        } else if (hours == 0) {
            hoursForDisplay = 12
            period = "a.m."
        } else {
            period = "a.m."
        }
        return String(format: "%d:%02d %@", hoursForDisplay, minutes, period)
    }
    
    var body: some View {
        NavigationView {
            List() {
                Section(header: Text("Total daily fat allowed")) {
                    Stepper(
                        String(format: "%.1fg", modelData.totalFat),
                        value: $modelData.totalFat,
                        in: 0...Double.infinity,
                        step: 1.0
                    )
                }
                Section(
                    header: Text("Reset daily fat time"),
                    footer: HStack() {
                        Spacer(minLength: 24)
                        Text("Each day at the chosen time, the amount of fat used during the day will be reset to 0.0g")
                            .multilineTextAlignment(.center)
                        Spacer(minLength: 24)
                    }
                ) {
                    DatePicker(
                        "Daily reset",
                        selection: $modelData.dateForResetSelection,
                        displayedComponents: .hourAndMinute
                    )
                    Button("Reset fat used now") {
                        modelData.usedFat = 0
                    }
                }
                Button("Give Feedback") {
                    
                }
                Button("Report a bug", role: .destructive) {
                    
                }
            }.navigationTitle("Settings")
        }
    }
}

struct CounterSettings_Previews: PreviewProvider {
    static var previews: some View {
        CounterSettings()
            .environmentObject(ModelData())
            .preferredColorScheme(.dark)
    }
}
