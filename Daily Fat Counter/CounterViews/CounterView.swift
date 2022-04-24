//
//  CounterView.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-03-27.
//

import SwiftUI

fileprivate var lastQuadrant: Geometry.Quadrant?

struct CounterView: View {
    let circleSize: Double = 160
    let touchZoneSize: Double = 160
    let handleSize: Double = 88
    let mode: Mode = .totalFat
    
    @Binding var usedGrams: Double
    @Binding var totalGrams: Double
    
    @State private var dragStarted = false
    @State private var dragGrabbed = false
    
    var progress: Double {
        usedGrams / totalGrams
    }
    
    var drag: some Gesture {
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
                let newQuadrant = Geometry.Quadrant(withPoint: location,
                                                    inCircleWithOrigin: origin)
                if (!dragStarted) {
                    dragGrabbed = abs(location.x - handle.x) < handleSize &&
                              abs(location.y - handle.y) < handleSize
                    lastQuadrant = newQuadrant
                    dragStarted = true
                }
                guard dragGrabbed,
                    Geometry.point(location,
                                   isInsideCircle: outerTouchCircle,
                                   atOrigin: origin),
                    !Geometry.point(location,
                                    isInsideCircle: innerTouchCircle,
                                    atOrigin: origin) else {
                    return
                }
                
                var opposite: Double
                var adjacent: Double
                var quadrantOffset: Double
                var completeRotations: Double = floor(progress)
                switch (newQuadrant) {
                case .one:
                    quadrantOffset = 0
                    opposite = location.x - origin.x
                    adjacent = origin.y - location.y
                    if (lastQuadrant == .four) {
                        completeRotations = round(progress)
                        DebugLog.log("Rotate forward #\(completeRotations)")
                    }
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
                    if (lastQuadrant == .one) {
                        completeRotations = max(round(progress) - 1, 0)
                        DebugLog.log("Rotate backward #\(completeRotations)")
                    }
                }
                lastQuadrant = newQuadrant
                let angle = atan(opposite / adjacent) + quadrantOffset
                withAnimation(.easeOut(duration: 0.1)) {
                    usedGrams = (angle / (2 * Double.pi)) * totalGrams + completeRotations * totalGrams
                }
            }
            .onEnded { gesture in
                dragStarted = false
                lastQuadrant = nil
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
