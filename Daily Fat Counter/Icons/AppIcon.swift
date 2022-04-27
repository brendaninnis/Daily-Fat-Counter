
import SwiftUI

struct AppIcon: View {
    
    static let appIconSize: Double = 512
    let angularGradient = AngularGradient(
        gradient: Gradient(colors: [
            Color.ui.paleGreen,
            Color.ui.paleYellow,
            Color.ui.paleYellow,
            Color.ui.paleGreen
        ]),
        center: .center,
        startAngle: .degrees(90),
        endAngle: .degrees(450)
    )
    let circleDiameter: Double = 372
    let plusLength: Double = 240
    let lineWidth: Double = 44
    
    var body: some View {
        
        ZStack {
            Color(UIColor.systemBackground)
            Circle()
                .stroke(angularGradient, lineWidth: lineWidth)
                .rotationEffect(.degrees(-90))
                .frame(width: circleDiameter, height: circleDiameter)
            Path { path in
                path.addPath(
                    RoundedRectangle(cornerRadius: lineWidth * 0.5)
                        .path(
                            in: CGRect(
                                x: Self.appIconSize * 0.5 - plusLength * 0.5,
                                y: Self.appIconSize * 0.5 - lineWidth * 0.5,
                                width: plusLength,
                                height: lineWidth
                            )
                        )
                )
                path.addPath(
                    RoundedRectangle(cornerRadius: lineWidth * 0.5).path(
                            in: CGRect(
                                x: Self.appIconSize * 0.5 - lineWidth * 0.5,
                                y: Self.appIconSize * 0.5 - plusLength * 0.5,
                                width: lineWidth,
                                height: plusLength
                            )
                        )
                )
            }
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.ui.paleYellow,
                        Color.ui.paleYellow,
                        Color.ui.paleGreen,
                        Color.ui.paleGreen
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }.frame(width: Self.appIconSize, height: Self.appIconSize)
    }
}

struct AppIcon_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppIcon()
                .previewLayout(.fixed(width: CGFloat(AppIcon.appIconSize), height: CGFloat(AppIcon.appIconSize)))
            AppIcon()
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: CGFloat(AppIcon.appIconSize), height: CGFloat(AppIcon.appIconSize)))
        }
    }
}
