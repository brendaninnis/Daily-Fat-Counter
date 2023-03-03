
import SwiftUI

struct HistoryGraph: View {
    let smallHeight: CGFloat = 4
    let largeHeight: CGFloat = 16
    @Binding var isAnimated: Bool
    var progress: CGFloat

    var body: some View {
        let startColor = Color.UI.gradientStartColor(
            withProgress: progress
        )
        let endColor = Color.UI.gradientEndColor(
            withProgress: progress
        )
        let linearGradient = LinearGradient(
            gradient: Gradient(colors: [
                startColor,
                endColor,
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .path(in: CGRect(
                        x: 0,
                        y: geometry.size.height * 0.5 - smallHeight * 0.5,
                        width: geometry.size.width,
                        height: smallHeight
                    ))
                    .fill(linearGradient)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.5))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.5))
                }
                .trim(from: 0, to: isAnimated ? min(progress, 1) : 0)
                .stroke(linearGradient, style: StrokeStyle(
                    lineWidth: largeHeight,
                    lineCap: .round,
                    lineJoin: .round
                ))
            }
        }
    }
}

struct HistoryGraph_Previews: PreviewProvider {
    static var previews: some View {
        HistoryGraph(isAnimated: .constant(true), progress: 0.7)
    }
}
