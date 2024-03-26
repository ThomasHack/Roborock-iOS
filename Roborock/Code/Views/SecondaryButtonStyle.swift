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
            .font(.system(size: 16))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .foregroundColor(foregroundColor.opacity(configuration.isPressed ? 0.9 : 1.0))
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 26))
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

#Preview {
    ZStack {
        Color(.secondarySystemBackground)
        SecondaryButton()
    }
}
