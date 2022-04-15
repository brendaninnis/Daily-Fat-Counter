//
//  HistoryHome.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-04-15.
//

import SwiftUI

struct HistoryHome: View {
    struct Month: Identifiable {
        let id: Int
        let name: String
        var dailyFat: [DailyFat]
    }
    
    @Binding var history: [DailyFat]
    private var months: [Month] {
        var months = [Month]()
        var currentMonth: Month?
        for (index, dailyFat) in history.enumerated() {
            let month = dailyFat.monthLabel
            if (currentMonth == nil || currentMonth!.name != month) {
                if (currentMonth != nil) {
                    months.append(currentMonth!)
                }
                currentMonth = Month(id: index, name: month, dailyFat: [])
            }
            currentMonth?.dailyFat.append(dailyFat)
        }
        if (currentMonth != nil) {
            months.append(currentMonth!)
        }
        return months
    }
    
    var body: some View {
        List() {
            ForEach(months) { month in
                Section(month.name) {
                    ForEach(month.dailyFat) { dailyFat in
                        HistoryRow(dailyFat: dailyFat)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

struct HistoryHome_Previews: PreviewProvider {
    static var previews: some View {
        HistoryHome(history: .constant([
            DailyFat(id: 0x07E60709, usedFat: 25, totalFat: 45),
            DailyFat(id: 0x07E6070A, usedFat: 45, totalFat: 45),
            DailyFat(id: 0x07E6070B, usedFat: 105, totalFat: 45),
            DailyFat(id: 0x07E6070C, usedFat: 30, totalFat: 45),
            DailyFat(id: 0x07E6070D, usedFat: 32, totalFat: 45),
            DailyFat(id: 0x07E6070E, usedFat: 10, totalFat: 45),
            DailyFat(id: 0x07E6070F, usedFat: 39, totalFat: 45),

            DailyFat(id: 0x07E60809, usedFat: 25, totalFat: 45),
            DailyFat(id: 0x07E6080A, usedFat: 45, totalFat: 45),
            DailyFat(id: 0x07E6080B, usedFat: 105, totalFat: 45),
            DailyFat(id: 0x07E6080C, usedFat: 30, totalFat: 45),
            DailyFat(id: 0x07E6080D, usedFat: 32, totalFat: 45),
            DailyFat(id: 0x07E6080E, usedFat: 10, totalFat: 45),
            DailyFat(id: 0x07E6080F, usedFat: 39, totalFat: 45),
            
            DailyFat(id: 0x07E60909, usedFat: 25, totalFat: 45),
            DailyFat(id: 0x07E6090A, usedFat: 45, totalFat: 45),
            DailyFat(id: 0x07E6090B, usedFat: 105, totalFat: 45),
            DailyFat(id: 0x07E6090C, usedFat: 30, totalFat: 45),
            DailyFat(id: 0x07E6090D, usedFat: 32, totalFat: 45),
            DailyFat(id: 0x07E6090E, usedFat: 10, totalFat: 45),
            DailyFat(id: 0x07E6090F, usedFat: 39, totalFat: 45),
        ]))
    }
}
