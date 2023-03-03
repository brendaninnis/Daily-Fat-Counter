
import CoreGraphics
import Foundation

class Geometry {
    enum Quadrant {
        case one
        case two
        case three
        case four

        init(withPoint point: CGPoint, inCircleWithOrigin origin: CGPoint) {
            // Quadrant one starts at 0 radians and ends before pi/2
            // This way we never divide by zero when using arctan
            if point.x >= origin.x {
                if point.y < origin.y {
                    self = .one
                } else {
                    self = .two
                }
            } else {
                if point.y >= origin.y {
                    self = .three
                } else {
                    self = .four
                }
            }
        }
    }
}
