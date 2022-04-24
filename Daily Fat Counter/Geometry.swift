//
//  Geometry.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-04-24.
//

import Foundation
import CoreGraphics

class Geometry {
    static func point(_ point: CGPoint, isInsideCircle circleSize: Double, atOrigin origin: CGPoint) -> Bool {
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
}
