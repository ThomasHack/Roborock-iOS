//
//  PrimaryButtonStyle.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Self.Configuration) -> some View {
        let foregroundColor = isEnabled ? Color("textColorDark") : Color(.tertiaryLabel)
        let backgroundColor = isEnabled ? Color(.systemBackground) : Color(.tertiarySystemBackground)

        return configuration.label
            .font(.system(size: 16))
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .foregroundColor(foregroundColor.opacity(configuration.isPressed ? 0.9 : 1.0))
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 26))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(color: .black.opacity(configuration.isPressed ? 0.0 : 0.2), radius: 4, x: 2, y: 2)
    }
}

struct SecondaryButton: View {
    var body: some View {
        Button {} label: {
            HStack {
                Image(systemName: "house.fill")
                Text("Label")
            }
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}

#Preview {
    ZStack {
        Color(.secondarySystemBackground)
        SecondaryButton()
    }
}
