
import SwiftUI

struct CounterSettings: View {
    @EnvironmentObject var counterData: CounterData

    struct FooterCompat<Content: View>: View {
        let content: Content

        init(@ViewBuilder _ content: () -> Content) {
            self.content = content()
        }

        var body: some View {
            content.multilineTextAlignment(.center)
        }
    }

    private var totalFatSection: some View {
        Section(
            header: Text("Total daily fat allowed"),
            footer: HStack {
                Spacer(minLength: 24)
                FooterCompat {
                    Text("Set a goal for your daily fat consumption")
                }
                Spacer(minLength: 24)
            }
        ) {
            HStack {
                Text(String(format: "%.1fg", counterData.totalFat))
            }
        }
    }

    private var resetFatSection: some View {
        Section(
            header: Text("Reset daily fat time"),
            footer: HStack {
                Spacer(minLength: 24)
                FooterCompat {
                    Text("Each day at the chosen time, the amount of fat used during the day will be reset to 0.0g")
                }
                Spacer(minLength: 24)
            }
        ) {
            #if os(iOS)
            DatePicker("Daily reset",
                       selection: $counterData.dateForResetSelection,
                       displayedComponents: .hourAndMinute)
            #else
            #endif
            Button("Reset fat used now") {
                counterData.usedFat = 0
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                totalFatSection
                resetFatSection
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
