//
//  CounterView.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-03-27.
//

import SwiftUI

struct CounterView: View {
    let circleSize: Double = 160
    let touchZoneSize: Double = 160
    let handleSize: Double = 88
    let mode: Mode = .totalFat
    
    @Binding var usedGrams: Double
    @Binding var totalGrams: Double
    
    var progress: Double {
        usedGrams / totalGrams
    }
    
    var drag: some Gesture {
        var grabbed = false
        var started = false
        let origin = CGPoint(x: circleSize * 0.5, y: circleSize * 0.5)
        let outerTouchCircle = circleSize + touchZoneSize * 0.5
        let innerTouchCircle = circleSize - touchZoneSize * 0.5
        
        return DragGesture()
            .onChanged { gesture in
                let handleAngle = 2 * Double.pi * progress
                let handle = CGPoint(
                    x: CGFloat(origin.x) + CGFloat(origin.x) * sin(handleAngle),
                    y: origin.y - origin.y * cos(handleAngle)
                )
                let location = gesture.location
                if (!started) {
                    grabbed = abs(location.x - handle.x) < handleSize &&
                              abs(location.y - handle.y) < handleSize
                    started = true
                }
                guard grabbed,
                    point(location, isInsideCircle: outerTouchCircle, atOrigin: origin),
                    !point(location, isInsideCircle: innerTouchCircle, atOrigin: origin) else {
                    return
                }
                var opposite: Double
                var adjacent: Double
                var quadrantOffset: Double
                switch (Quadrant(withPoint: location, inCircleWithOrigin: origin)) {
                case .one:
                    quadrantOffset = 0
                    opposite = location.x - origin.x
                    adjacent = origin.y - location.y
                case .two:
                    quadrantOffset = Double.pi * 0.5
                    opposite = location.y - origin.y
                    adjacent = location.x - origin.x
                case .three:
                    quadrantOffset = Double.pi
                    opposite = origin.x - location.x
                    adjacent = location.y - origin.y
                case .four:
                    quadrantOffset = Double.pi * 1.5
                    opposite = origin.y - location.y
                    adjacent = origin.x - location.x
                }
                let angle = atan(opposite / adjacent) + quadrantOffset
                withAnimation(.easeOut(duration: 0.1)) {
                    usedGrams = round((angle / (2 * Double.pi)) * totalGrams)
                }
            }
            .onEnded { gesture in
                started = false
            }
    }
    
    var body: some View {
        let startColor = Color.UI.gradientStartColor(withProgress: progress)
        let endColor = Color.UI.gradientEndColor(withProgress: progress)
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
                    Text(String(format: "%.1fg", usedGrams))
                        .font(.largeTitle)
                        .bold()
                    Text(String(format: "/ %.1fg", totalGrams))
                        .font(.subheadline)
                        .bold()
                }
            }.gesture(drag)
            Text(mode.rawValue)
                .font(.headline)
                .padding()
        }
    }
    
    func point(_ point: CGPoint, isInsideCircle circleSize: Double, atOrigin origin: CGPoint) -> Bool {
        return pow(point.x - origin.x, 2) + pow(point.y - origin.y, 2) < pow(circleSize * 0.5, 2)
    }
        
    enum Quadrant {
        case one
        case two
        case three
        case four
        
        init(withPoint point: CGPoint, inCircleWithOrigin origin: CGPoint) {
            // Quadrant one starts at 0 radians and ends before pi/2
            // This way we never divide by zero when using arctan
            if (point.x >= origin.x) {
                if (point.y < origin.y) {
                    self = .one
                } else {
                    self = .two
                }
            } else {
                if (point.y >= origin.y) {
                    self = .three
                } else {
                    self = .four
                }
            }
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
