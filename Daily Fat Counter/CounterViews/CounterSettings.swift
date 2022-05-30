
import SwiftUI

struct CounterSettings: View {
    @EnvironmentObject var counterData: CounterData
    
    private var hours: Int {
        counterData.resetTime / SECONDS_PER_HOUR
    }
    private var minutes: Int {
        (counterData.resetTime % SECONDS_PER_HOUR) / SECONDS_PER_MINUTE
    }
    private var displayTime: String {
        let period: String
        var hoursForDisplay = hours
        if (hoursForDisplay > 12) {
            period = "p.m."
            hoursForDisplay -= 12
        } else if (hoursForDisplay == 12) {
            period = "p.m."
        } else if (hoursForDisplay == 0) {
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
                Section(
                    header: Text("Total daily fat allowed"),
                    footer: HStack() {
                        Spacer(minLength: 24)
                        Text("Set a goal for your daily fat consumption")
                            .multilineTextAlignment(.center)
                        Spacer(minLength: 24)
                    }
                ) {
                    Stepper(
                        String(format: "%.1fg", counterData.totalFat),
                        value: $counterData.totalFat,
                        in: 1...Double.infinity,
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
                        selection: $counterData.dateForResetSelection,
                        displayedComponents: .hourAndMinute
                    )
                    Button("Reset fat used now") {
                        counterData.usedFat = 0
                    }
                }
                Section() {
                    Button("Give Feedback") {
                        
                    }
                    if #available(iOS 15.0, *) {
                        Button("Report a bug", role: .destructive) {
                            
                        }
                    } else {
                        Button() {
                            
                        } label: {
                            Text("Report a bug")
                                .foregroundColor(Color.red)
                        }
                    }
                }
            }.navigationTitle("Settings")
        }
    }
}

struct CounterSettings_Previews: PreviewProvider {
    static var previews: some View {
        CounterSettings()
            .environmentObject(CounterData())
            .preferredColorScheme(.dark)
    }
}
