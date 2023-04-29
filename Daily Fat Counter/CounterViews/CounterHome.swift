
import StoreKit
import SwiftUI

struct CounterHome: View {
    static let lastVersionPromptedForReviewKey = "lastVersionPromptedForReviewKey"

    let date = Date()
    @EnvironmentObject var counterData: CounterData
    @EnvironmentObject var dailyData: DailyFatStore

    @State private var reviewTask: Task<Void, Never>?

    var body: some View {
        VStack(alignment: .leading) {
            Text(currentDateFormatter.string(from: date))
                .font(.title)
            Spacer()
            HStack {
                Spacer()
                InteractiveCounter(
                    usedGrams: $counterData.usedFat,
                    totalGrams: $counterData.totalFat
                )
                Spacer()
            }
            Spacer()
            HStack {
                Spacer()
                ForEach([1, 5, 10], id: \.self) { value in
                    CounterButton(value: value) {
                        withAnimation(.easeInOut) {
                            counterData.usedFat += Double(value)
                        }
                    }.padding(4)
                }
                Spacer()
            }
        }
        .padding()
        .onChange(of: counterData.usedFat) { newValue in
            guard newValue > 0 else {
                return
            }
            // Prompt for review when the user sets used fat
            promptForAppStoreReviewIfNeeded()
        }
        .onDisappear {
            // Avoid prompting for review when the user switches tabs
            reviewTask?.cancel()
        }
    }

    @available(iOSApplicationExtension, unavailable)
    @available(watchOS, unavailable)
    private func promptForAppStoreReviewIfNeeded() {
        guard let defaults = CounterData.defaults else {
            DebugLog.log("Failed to get UserDefaults")
            return
        }
        // Keep track of the most recent app version that prompts the user for a review.
        let lastVersionPromptedForReview = defaults.string(forKey: Self.lastVersionPromptedForReviewKey)
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            fatalError("Expected to find a bundle version in the info dictionary.")
        }

        // Verify the user has more than 1 day of history and doesn’t receive a prompt for this app version.
        if dailyData.history.count > 1 && currentVersion != lastVersionPromptedForReview {
            reviewTask?.cancel()
            reviewTask = Task { @MainActor in
                // Delay for two seconds to avoid interrupting the person using the app.
                // Use the equation n * 10^9 to convert seconds to nanoseconds.
                do {
                    try await Task.sleep(nanoseconds: UInt64(2e9))
                } catch {
                    DebugLog.log("Review task cancelled")
                    return
                }

                // try getting current scene
                guard let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    DebugLog.log("Unable to get current scene")
                    return
                }

                // show review dialog
                SKStoreReviewController.requestReview(in: currentScene)
                CounterData.defaults?.set(currentVersion, forKey: Self.lastVersionPromptedForReviewKey)
            }
        }
    }
}

struct CounterHome_Previews: PreviewProvider {
    static var previews: some View {
        CounterHome()
            .environmentObject(CounterData())
    }
}
