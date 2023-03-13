//
//  CounterView.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2023-03-03.
//

import SwiftUI

struct CounterView: View {
    let usedGrams: Double
    let totalGrams: Double

    var progress: Double {
        usedGrams / totalGrams
    }
    
    private var counterFont: Font {
        if Bundle.main.bundlePath.hasSuffix(".appex") {
            // App extension (Widget)
            return .caption
        }
        return .largeTitle
    }
    
    private var goalFont: Font {
        if Bundle.main.bundlePath.hasSuffix(".appex") {
            // App extension (Widget)
            return .caption
        }
        return .headline
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

        GeometryReader { geometry in
            VStack {
                ZStack {
                    Circle()
                        .stroke(angularGradient, lineWidth: geometry.size.width * 0.025)
                        .rotationEffect(.degrees(-90))
                        .frame(width: geometry.size.width, height: geometry.size.width)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            angularGradient,
                            style: StrokeStyle(
                                lineWidth: geometry.size.width * 0.1,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: geometry.size.width, height: geometry.size.width)
                    VStack(alignment: .center) {
                        Text(String(format: "%.1fg", round(usedGrams)))
                            .font(counterFont)
                            .bold()
                        Text(String(format: "/ %.1fg", totalGrams))
                            .font(goalFont)
                            .bold()
                    }
                }
            }
        }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(usedGrams: 28.0, totalGrams: 45.0)
            .frame(width: 160.0, height: 160.0)
    }
}
