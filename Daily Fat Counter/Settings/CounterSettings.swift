
#if canImport(MessageUI)
import MessageUI
#endif
import SwiftUI

struct CounterSettings: View {
    @EnvironmentObject var counterData: CounterData

    @State private var showingFeedbackAlert = false
    @State private var showingMail = false
    #if canImport(MessageUI)
    @State var result: Result<MFMailComposeResult, Error>? = nil
    #endif
    private let feedbackUrl = "https://apps.apple.com/app/id1631074004?action=write-review"

    struct FooterCompat<Content: View>: View {
        let content: Content

        init(@ViewBuilder _ content: () -> Content) {
            self.content = content()
        }

        var body: some View {
            if #available(iOS 15.0, *) {
                content.multilineTextAlignment(.center)
            } else {
                content.multilineTextAlignment(.center)
                    .font(.footnote)
            }
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
            Stepper(
                String(format: "%.1fg", counterData.totalFat),
                value: $counterData.totalFat,
                in: 1 ... Double.infinity,
                step: 1.0
            )
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
            DatePicker("Daily reset",
                       selection: $counterData.dateForResetSelection,
                       displayedComponents: .hourAndMinute)
            Button("Reset fat used now") {
                counterData.usedFat = 0
            }
        }
    }

    private var feedbackSection: some View {
        Section {
            Button("Give Feedback") {
                guard let writeReviewURL = URL(string: feedbackUrl) else {
                    fatalError("Expected a valid URL")
                }
                UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
            }
            if #available(iOS 15.0, *) {
                Button("Report a bug", role: .destructive) {
                    showReportBugFlow()
                }
            } else {
                Button {
                    showReportBugFlow()
                } label: {
                    Text("Report a bug")
                        .foregroundColor(Color.red)
                }
            }
        }
    }

    private func showReportBugFlow() {
        if !MFMailComposeViewController.canSendMail() {
            showingFeedbackAlert = true
            return
        }
        showingMail = true
    }

    var body: some View {
        NavigationView {
            List {
                totalFatSection
                resetFatSection
                feedbackSection
            }.navigationTitle("Settings")
        }
        #if canImport(MessageUI)
        .sheet(isPresented: $showingMail) {
            MailView(isShowing: $showingMail, result: $result)
        }
        #endif
        .alert(isPresented: $showingFeedbackAlert) {
            Alert(title: Text("Email not configured"),
                  message: Text("Your device is not setup to send email. Please email the developer of Daily Fat Counter at brendaninnis@icloud.com"))
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
