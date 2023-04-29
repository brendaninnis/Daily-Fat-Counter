
import SwiftUI

private var lastQuadrant: Geometry.Quadrant = .one
private var lastAngle: Double = 0

struct InteractiveCounter: View {
    static let circleSize: Double = 160

    let touchZoneSize: Double = Self.circleSize
    let handleSize: Double = Self.circleSize * 0.5 + 8
    let mode: Mode = .totalFat

    @Binding var usedGrams: Double
    @Binding var totalGrams: Double

    @State private var dragStarted = false

    var drag: some Gesture {
        let origin = CGPoint(x: Self.circleSize * 0.5, y: Self.circleSize * 0.5)

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
        VStack {
            CounterView(usedGrams: usedGrams, totalGrams: totalGrams)
                .frame(width: Self.circleSize, height: Self.circleSize)
                .gesture(drag)
            #if os(watchOS)
                .focusable()
                .digitalCrownRotation($usedGrams,
                                      from: 0,
                                      through: totalGrams * 5,
                                      by: 1.0,
                                      sensitivity: .medium)
            #endif

            #if os(watchOS)
            // Compact view for watch
            #else
                Text(mode.rawValue)
                    .font(.headline)
                    .padding()
            #endif
        }
    }

    enum Mode: String, CaseIterable, Codable {
        case totalFat = "Total Fat"
        case remainingFat = "Remaining Fat"
    }
}

struct InteractiveCounter_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveCounter(usedGrams: .constant(28.0), totalGrams: .constant(45.0))
            .preferredColorScheme(.dark)
    }
}
