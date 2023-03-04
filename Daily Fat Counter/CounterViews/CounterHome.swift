
import SwiftUI

struct CounterHome: View {
    let date = Date()
    @EnvironmentObject var counterData: CounterData

    var body: some View {
        VStack(alignment: .leading) {
            Text(currentDateFormatter.string(from: date))
                .font(.title)
            Spacer()
            HStack {
                Spacer()
                VStack {
                    InteractiveCounter(
                        usedGrams: $counterData.usedFat,
                        totalGrams: $counterData.totalFat
                    )
                }
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
    }
}

struct CounterHome_Previews: PreviewProvider {
    static var previews: some View {
        CounterHome()
            .environmentObject(CounterData())
    }
}
