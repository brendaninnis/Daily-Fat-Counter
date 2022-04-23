//
//  HistoryRow.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-04-15.
//

import SwiftUI

struct HistoryRow: View {
    let dailyFat: DailyFat
    @Environment(\.colorScheme) var colorScheme
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
        HistoryRow(dailyFat: DailyFat(id: 0x07E60809, usedFat: 35, totalFat: 45), isAnimated: .constant(false))
    }
}
