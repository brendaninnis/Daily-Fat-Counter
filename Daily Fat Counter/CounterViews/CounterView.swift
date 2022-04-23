//
//  CounterView.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-03-27.
//

import SwiftUI

struct CounterView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let mode: Mode = .totalFat;
    @Binding var usedGrams: Double;
    @Binding var totalGrams: Double;
    var progress: Double {
        usedGrams / totalGrams
    }
    
    var body: some View {
        let startColor = Color.UI.gradientStartColor(
            withProgress: progress,
            inColorScheme: colorScheme
        )
        let endColor = Color.UI.gradientEndColor(
            withProgress: progress,
            inColorScheme: colorScheme
        )
        let gradient = Gradient(colors: [
            startColor,
            endColor,
            endColor,
            startColor
        ])
        let angularGradient = AngularGradient(
            gradient: gradient,
            center: .center,
            startAngle: .degrees(90),
            endAngle: .degrees(450)
        )

        VStack {
            ZStack {
                Circle()
                    .stroke(angularGradient, lineWidth: 4.0)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 160, height: 160)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        angularGradient,
                        style: StrokeStyle(
                            lineWidth: 16.0,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 160, height: 160)
                    .animation(.easeInOut, value: progress)
                VStack(alignment: .leading) {
                    Text(String(format: "%.1fg", usedGrams))
                        .font(.largeTitle)
                        .bold()
                    Text(String(format: "/ %.1fg", totalGrams))
                        .font(.subheadline)
                        .bold()
                }
            }
            Text(mode.rawValue)
                .font(.headline)
                .padding()
        }
    }
    enum Mode: String, CaseIterable, Codable {
        case totalFat = "Total Fat"
        case remainingFat = "Remaining Fat"
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(usedGrams: .constant(28.0), totalGrams: .constant(45.0))
            .preferredColorScheme(.dark)
    }
}
