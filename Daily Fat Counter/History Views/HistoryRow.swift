
import SwiftUI

struct HistoryRow: View {
    var dailyFat: DailyFat
    @Binding var isAnimated: Bool
    var body: some View {
        HStack(spacing: 8) {
            Text(dailyFat.dateLabel)
                .frame(minWidth: 160, alignment: .leading)
            HistoryGraph(isAnimated: $isAnimated, progress: CGFloat(dailyFat.usedFat) / CGFloat(dailyFat.totalFat))
        }
    }
}

struct HistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        HistoryRow(dailyFat: DailyFat(id: 0,
                                      start: 1_654_637_866,
                                      usedFat: 35,
                                      totalFat: 45),
                   isAnimated: .constant(false))
    }
}
