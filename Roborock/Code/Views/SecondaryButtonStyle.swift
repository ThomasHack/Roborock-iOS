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
        let foregroundColor = isEnabled ? Color("blue-primary") : Color(.tertiaryLabel)
        let backgroundColor = isEnabled ? Color(.systemBackground) : Color(.tertiarySystemBackground)

        return configuration.label
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .foregroundColor(foregroundColor.opacity(configuration.isPressed ? 0.9 : 1.0))
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
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

struct SecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground)
            SecondaryButton()
        }
    }
}
