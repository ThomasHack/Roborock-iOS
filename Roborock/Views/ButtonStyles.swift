//
//  ButtonStyles.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import SwiftUI

struct StatusButtonStyle: ButtonStyle {
    var active = false
    var disabled = false

    func makeBody(configuration: Self.Configuration) -> some View {
        let background = disabled
            ? Color(UIColor.tertiarySystemFill)
            : Color(UIColor.systemBackground)

        let foreground = disabled ? Color(UIColor.secondaryLabel) : Color(UIColor.label)

        return configuration.label
            .foregroundColor(foreground)
            .background(background)
            .background(BlurView().opacity(active ? 1.0 : 0.2))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color(.systemBackground), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
