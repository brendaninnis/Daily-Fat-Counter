
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
    let circleDiameter: Double = 400
    let plusLength: Double = 122
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
                        .path(in: CGRect(
                            x: 158,
                            y: Self.appIconSize * 0.5 - lineWidth * 0.5,
                            width: lineWidth,
                            height: 136
                        ))
                )
                path.addPath(
                    RoundedRectangle(cornerRadius: lineWidth * 0.5)
                        .path(in: CGRect(
                            x: 113,
                            y: Self.appIconSize * 0.5 - lineWidth * 0.5,
                            width: 142,
                            height: lineWidth
                        ))
                )
                path.addPath(
                    RoundedRectangle(cornerRadius: lineWidth * 0.5)
                        .path(
                            in: CGRect(
                                x: 276,
                                y: Self.appIconSize * 0.5 - lineWidth * 0.5,
                                width: plusLength,
                                height: lineWidth
                            )
                        )
                )
                path.addPath(
                    RoundedRectangle(cornerRadius: lineWidth * 0.5).path(
                            in: CGRect(
                                x: 276 + plusLength * 0.5 - lineWidth * 0.5,
                                y: Self.appIconSize * 0.5 - plusLength * 0.5,
                                width: lineWidth,
                                height: plusLength
                            )
                        )
                )
                path.addPath(
                    Ellipse()
                        .trim(from: 0, to: 0.25)
                        .rotation(.degrees(180))
                        .stroke(style: StrokeStyle(
                            lineWidth: lineWidth
                        ))
                        .path(in: CGRect(
                            x: 178,
                            y: 164,
                            width: 110,
                            height: 140
                        ))
                )
                path.addPath(
                    Ellipse()
                        .trim(from: 0.1, to: 0.25)
                        .rotation(.degrees(180))
                        .stroke(style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round
                        ))
                        .path(in: CGRect(
                            x: 178,
                            y: 164,
                            width: 110,
                            height: 140
                        ))
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
