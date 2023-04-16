
import SwiftUI

struct GoalSetting: View {
    @Binding var totalGrams: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            HStack(alignment: .bottom) {
                Text("My Goal")
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1fg", totalGrams))
                .font(.title3)
                .bold()
                .focusable()
                .digitalCrownRotation($totalGrams,
                                      from: 0,
                                      through: 100,
                                      by: 1,
                                      sensitivity: .medium)
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            Text("Twist the crown to adjust")
                .font(.footnote)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            Spacer()
        }.navigationTitle("Settings")
    }
}

struct GoalSetting_Previews: PreviewProvider {
    static var previews: some View {
        GoalSetting(totalGrams: .constant(45.0))
    }
}
