
import SwiftUI

private var lastQuadrant: Geometry.Quadrant = .one
private var lastAngle: Double = 0

struct CounterView: View {
    let circleSize: Double = 160
    let touchZoneSize: Double = 160
    let handleSize: Double = 88
    let mode: Mode = .totalFat

    @Binding var usedGrams: Double
    @Binding var totalGrams: Double

    @State private var dragStarted = false

    var progress: Double {
        usedGrams / totalGrams
    }

    var drag: some Gesture {
        let origin = CGPoint(x: circleSize * 0.5, y: circleSize * 0.5)

        return DragGesture()
            .onChanged { gesture in
                let location = gesture.location

                let opposite: Double
                let adjacent: Double
                let quadrantOffset: Double

                let newQuadrant = Geometry.Quadrant(withPoint: location,
                                                    inCircleWithOrigin: origin)
                switch newQuadrant {
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

                if !dragStarted {
                    dragStarted = true
                    lastAngle = angle
                    lastQuadrant = newQuadrant
                    return
                }
                var rotationOffset: Double = 0
                if newQuadrant == .one && lastQuadrant == .four {
                    // Rotation forward
                    rotationOffset = RADIANS_PER_ROTATION
                } else if newQuadrant == .four && lastQuadrant == .one {
                    // Rotation backward
                    rotationOffset = -1 * RADIANS_PER_ROTATION
                }

                // Updates the UI
                usedGrams += ((angle - lastAngle + rotationOffset) / RADIANS_PER_ROTATION) * totalGrams
                if usedGrams < 0 {
                    usedGrams = 0
                }

                lastAngle = angle
                lastQuadrant = newQuadrant
            }
            .onEnded { _ in
                dragStarted = false
            }
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
