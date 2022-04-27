
import Foundation
import SwiftUI

extension Color {
    static let ui = Color.UI()
    
    struct UI {
        let white = Color("White")
        let background = Color("Background")
        let paleGreen = Color("PaleGreen")
        let paleYellow = Color("PaleYellow")
        let paleRed = Color("Red")
        let onGreen = Color("OnGreen")
        
        static func gradientStartColor(withProgress progress: Double) -> Color {
            let startTransformPercent = progress > 1 ? min(progress - 1, 1) : 0
            let paleGreen = UIColor(named: "PaleGreen")!
            let paleRed = UIColor(named: "Red")!
            return getColor(
                from: paleGreen,
                to: paleRed,
                byPercent: startTransformPercent
            )
        }
        
        static func gradientEndColor(withProgress progress: Double) -> Color {
            let endTransformPercent = progress > 2 ? min(progress - 2, 1) : 0
            let paleYellow = UIColor(named: "PaleYellow")!
            let paleRed = UIColor(named: "Red")!
            return getColor(
                from: paleYellow,
                to: paleRed,
                byPercent: endTransformPercent
            )
        }
    }
    
    static func getColor(from fromColor: UIColor, to toColor: UIColor, byPercent percent: Double) -> Color {
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        return Color(UIColor(
            red: getTransition(
                from: fromRed,
                to: toRed,
                byPercent: percent),
            green: getTransition(
                from: fromGreen,
                to: toGreen,
                byPercent: percent),
            blue: getTransition(
                from: fromBlue,
                to: toBlue,
                byPercent: percent),
            alpha: 1))
    }
    
    private static func getTransition(from start: CGFloat,
                                      to end: CGFloat,
                                      byPercent percent: Double) -> CGFloat {
        return start + (end - start) * percent
    }
}
