//
//  HistoryGraph.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-04-15.
//

import SwiftUI

struct HistoryGraph: View {
    let linearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.ui.paleGreen,
            Color.ui.paleYellow
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    var progress: CGFloat {
        didSet {
            if (progress > 1) {
                progress = 1
            }
        }
    }
    
    init(progress: CGFloat) {
        self.progress = progress > 1 ? 1 : progress
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .path(in: CGRect(x: 0, y: geometry.size.height * 0.5 - 2, width: geometry.size.width, height: 4))
                    .fill(linearGradient)
                RoundedRectangle(cornerRadius: 8)
                    .path(in: CGRect(x: 0, y: geometry.size.height * 0.5 - 8, width: geometry.size.width * progress, height: 16))
                    .fill(linearGradient)
            }
        }
    }
}

struct HistoryGraph_Previews: PreviewProvider {
    static var previews: some View {
        HistoryGraph(progress: 0.7)
    }
}
