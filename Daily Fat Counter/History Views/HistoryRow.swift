
import SwiftUI

struct HistoryRow: View {
    let dailyFat: DailyFat
    let useShortDate: Bool

    @Binding var isAnimated: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text(useShortDate ? dailyFat.shortDateLabel : dailyFat.dateLabel)
                .frame(width: useShortDate ? 60 : 160,
                       height: 22,
                       alignment: .leading)
            HistoryGraph(isAnimated: $isAnimated, progress: CGFloat(dailyFat.usedFat) / CGFloat(dailyFat.totalFat))
                .frame(height: 22)
        }
    }

    init(dailyFat: DailyFat, useShortDate: Bool = false, isAnimated: Binding<Bool>) {
        self.dailyFat = dailyFat
        self.useShortDate = useShortDate
        _isAnimated = isAnimated
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
