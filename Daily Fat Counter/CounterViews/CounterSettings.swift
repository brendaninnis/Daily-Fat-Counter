//
//  CounterSettings.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-04-03.
//

import SwiftUI

struct CounterSettings: View {
    @Binding var totalFat: Double;
    @Binding var resetTime: Int;
    
    private var hours: Int {
        resetTime / SECONDS_PER_HOUR
    }
    private var minutes: Int {
        (resetTime % SECONDS_PER_HOUR) / SECONDS_PER_MINUTE
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
        VStack(alignment: .leading) {
            Text("Settings")
                .font(.title)
            VStack(alignment: .leading) {
                Text("Total daily fat allowed")
                    .foregroundColor(.secondary)
                Stepper(
                    String(format: "%.1fg", totalFat),
                    value: $totalFat,
                    in: 0...Double.infinity,
                    step: 1.0
                )
                .padding(8)
            }.padding(8)
            VStack(alignment: .leading) {
                Text("Reset daily fat at")
                    .foregroundColor(.secondary)
                Text(displayTime)
                    .padding(8)
            }.padding(8)
            Button("Report a bug") {
                
            }.padding(16)
        }.padding(8)
    }
}

struct CounterSettings_Previews: PreviewProvider {
    static var previews: some View {
        CounterSettings(totalFat: .constant(45.0), resetTime: .constant(57600))
            .preferredColorScheme(.dark)
    }
}
