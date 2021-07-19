//
//  CircularProgressViewStyle.swift
//  WatchApp Extension
//
//  Created by Thomas Hack on 17.07.21.
//

import SwiftUI

struct CircularProgressViewStyle: ProgressViewStyle {
    var tintColor: Color

    private let strokeWidth = 5.0

    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0

        return ZStack {
            Circle()
                .stroke(tintColor.opacity(0.3), style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle()
                .trim(from: 0, to: CGFloat(fractionCompleted))
                .stroke(tintColor, style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        // .frame(width: 24, height: 24, alignment: .center)
        .padding(2)
    }
}
