//
//  PrimaryButtonStyle.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 01.12.23.
//

import SwiftUI

struct PrimaryRoundedButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.colorScheme) private var colorScheme

    private var foregroundColor: Color {
        colorScheme == .light ? Color("textColorDark") : Color("textColorLight")
    }

    private var backgroundColor: Color {
        Color("backgroundColorLight")
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        let foregroundColor = isEnabled ? self.foregroundColor : Color("tertiaryLabel")
        let backgroundColor = isEnabled ? self.backgroundColor : Color("tertiarySystemBackground")
        let animation = Animation.spring()

        return configuration.label
            .font(.title3)
            .padding(36)
            .foregroundColor(foregroundColor)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.9 : 1.0))
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .scaleEffect(isFocused ? 1.1 : 1.0)
            .animation(animation, value: isFocused)
            .shadow(color: Color(white: 0.2).opacity(0.3), radius: 20)
    }
}

struct PrimaryButton: View {
    var body: some View {
        Button {} label: {
            Image(systemName: "house.fill")
        }
        .buttonStyle(PrimaryRoundedButtonStyle())
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButton().preferredColorScheme(.dark)
        PrimaryButton().preferredColorScheme(.light)
    }
}
