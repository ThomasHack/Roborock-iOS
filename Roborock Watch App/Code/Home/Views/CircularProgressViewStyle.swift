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
        let background = #colorLiteral(red: 0.04051336511, green: 0.07919989333, blue: 0.1560822571, alpha: 1)
        let north = #colorLiteral(red: 0.7809731364, green: 0.8558418155, blue: 1, alpha: 1)
        let east = #colorLiteral(red: 0.5547400332, green: 0.6814477352, blue: 0.9380942583, alpha: 1)
        let south = #colorLiteral(red: 0.1813787222, green: 0.7224964499, blue: 0.6189525723, alpha: 1)
        let west = #colorLiteral(red: 0, green: 0.8174446225, blue: 0.618026793, alpha: 1)
        let shadow = #colorLiteral(red: 0.06359451264, green: 0.1243214086, blue: 0.245004952, alpha: 1)

        return Circle()
            .stroke(Color(background), style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
            .overlay(
                Circle()
                    .trim(from: 0, to: CGFloat(fractionCompleted))
                    .stroke(AngularGradient(
                        gradient: Gradient(colors: [
                            Color(north),
                            Color(east),
                            Color(south),
                            Color(west)
                        ]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * 0.9)), style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
                    .rotationEffect(.degrees(-90))
            )
            .overlay(Circle()
                        .trim(from: 0, to: 0.01)
                        .stroke(
                            Color(north),
                            style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
                        .rotationEffect(.degrees(-90))
            )
            .overlay(
                Circle()
                    .trim(from: 0.9, to: CGFloat(fractionCompleted))
                    .stroke(fractionCompleted > 0.9 ? Color(west) : Color.clear,
                            style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .shadow(color: Color(shadow).opacity(0.4), radius: 2, x: 4, y: 0)
            )
            .padding(4)
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
