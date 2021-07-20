//
//  CircularProgressViewStyle.swift
//  WatchApp Extension
//
//  Created by Thomas Hack on 17.07.21.
//

import SwiftUI

struct CircularProgressViewStyle: ProgressViewStyle {
    private let strokeWidth = 8.0

    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0
        let background = #colorLiteral(red: 0.06939987838, green: 0.07400544733, blue: 0.06823639572, alpha: 1)
        let orange = #colorLiteral(red: 0.9875745177, green: 0.659271419, blue: 0.2163393199, alpha: 1)
        let green = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)
        let shadowGreen = #colorLiteral(red: 0.03670389205, green: 0.1547718048, blue: 0.02876702696, alpha: 1)

        Circle()
            .stroke(Color(background), style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
            .overlay(
                Circle()
                    .trim(from: 0, to: CGFloat(fractionCompleted))
                    .stroke(AngularGradient(
                        gradient: Gradient(colors: [
                            Color(#colorLiteral(red: 0.9875745177, green: 0.659271419, blue: 0.2163393199, alpha: 1)),
                            Color(#colorLiteral(red: 0.9960246682, green: 0.9582805037, blue: 0, alpha: 1)),
                            Color(#colorLiteral(red: 0.5500606894, green: 1, blue: 0, alpha: 1)),
                            Color(#colorLiteral(red: 0, green: 1, blue: 0, alpha: 1))
                        ]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * 0.9)), style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
                    .rotationEffect(.degrees(-90))
            )
            .overlay(Circle()
                        .trim(from: 0, to: 0.01)
                        .stroke(
                            Color(orange),
                            style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
                        .rotationEffect(.degrees(-90))
            )
            .overlay(
                Circle()
                    .trim(from: 0.9, to: CGFloat(fractionCompleted))
                    .stroke(fractionCompleted > 0.9 ? Color(green) : Color.clear,
                            style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .shadow(color: Color(shadowGreen).opacity(0.4), radius: 2, x: 4, y: 0)
            )
            .padding(CGFloat(strokeWidth) / 2)
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        let percentage = 56
        VStack {
            ProgressView("\(100)", value: Float(100), total: Float(100))
                .progressViewStyle(CircularProgressViewStyle())
            ProgressView("\(percentage)", value: Float(percentage), total: Float(100))
                .progressViewStyle(CircularProgressViewStyle())
        }
    }
}
