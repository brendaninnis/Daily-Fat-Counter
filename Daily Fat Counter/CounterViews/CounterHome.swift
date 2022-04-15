//
//  CounterHome.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-04-02.
//

import SwiftUI

struct CounterHome: View {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        formatter.timeZone = TimeZone(abbreviation: "PST")
        return formatter
    }()
    
    let date = Date()
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(CounterHome.dateFormatter.string(from: date))
                .font(.title2)
            Spacer()
            HStack {
                Spacer()
                VStack {
                    CounterView(
                        usedGrams: $modelData.usedFat,
                        totalGrams: $modelData.totalFat
                    )
                }
                Spacer()
            }
            Spacer()
            HStack {
                Spacer()
                ForEach([1, 5, 10], id: \.self) { value in
                    CounterButton(value: value) {
                        modelData.usedFat += Double(value)
                    }.padding(4)
                }
                Spacer()
            }
        }
        .padding()
    }
    
    init() {
        UITabBar.appearance().barTintColor = UIColor.secondarySystemBackground
    }
}

struct CounterHome_Previews: PreviewProvider {
    static var previews: some View {
        CounterHome()
            .environmentObject(ModelData())
            .previewInterfaceOrientation(.portrait)
    }
}
