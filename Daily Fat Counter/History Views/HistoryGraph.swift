//
//  HistoryGraph.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-04-15.
//

import SwiftUI

struct HistoryGraph: View {
    let smallHeight: CGFloat = 4
    let largeHeight: CGFloat = 16
    let linearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.ui.paleGreen,
            Color.ui.paleYellow
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    @Binding var isAnimated: Bool
    var progress: CGFloat {
        didSet {
            if (progress > 1) {
                progress = 1
            }
        }
    }
    
    init(isAnimated: Binding<Bool>, progress: CGFloat) {
        self._isAnimated = isAnimated
        self.progress = progress > 1 ? 1 : progress
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .path(in: CGRect(
                        x: 0,
                        y: geometry.size.height * 0.5 - smallHeight * 0.5,
                        width: geometry.size.width,
                        height: smallHeight))
                    .fill(linearGradient)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.5))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.5))
                }
                .trim(from: 0, to: isAnimated ? progress : 0)
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
