//
//  CounterView.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2023-03-03.
//

import SwiftUI

struct CounterView: View {
    let circleSize: Double
    let usedGrams: Double
    let totalGrams: Double

    var progress: Double {
        usedGrams / totalGrams
    }

    var body: some View {
        let startColor = Color.UI.gradientStartColor(withProgress: progress)
        let endColor = Color.UI.gradientEndColor(withProgress: progress)
        let gradient = Gradient(colors: [
            startColor,
            endColor,
            endColor,
            startColor,
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
                    .frame(width: circleSize, height: circleSize)
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
                    .frame(width: circleSize, height: circleSize)
                VStack(alignment: .leading) {
                    Text(String(format: "%.1fg", round(usedGrams)))
                        .font(.largeTitle)
                        .bold()
                    Text(String(format: "/ %.1fg", totalGrams))
                        .font(.subheadline)
                        .bold()
                }
            }
        }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(circleSize: 160.0, usedGrams: 28.0, totalGrams: 45.0)
    }
}
