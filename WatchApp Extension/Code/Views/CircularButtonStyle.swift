//
//  CircularButtonStyle.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 19.07.21.
//

import SwiftUI
import UIKit

struct CircularButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Self.Configuration) -> some View {
        let foregroundColor = isEnabled ? Color.white : Color.gray
        let backgroundColor = isEnabled ? Color(.secondaryBackground) : Color.black

        return configuration.label
            .fixedSize(horizontal: true, vertical: false)
            .frame(minWidth: 44)
            .frame(minHeight: 44)
            .foregroundColor(foregroundColor)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.9 : 1.0))
            .cornerRadius(44)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct CircularButton: View {
    var body: some View {
        Button {} label: {
            Image(systemName: "house.fill")
        }
        .buttonStyle(CircularButtonStyle())
    }
}

struct CircularButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CircularButton()
        }
        .previewLayout(.fixed(width: 224, height: 184))
    }
}
