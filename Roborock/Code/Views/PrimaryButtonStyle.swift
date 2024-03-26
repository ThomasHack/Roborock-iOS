//
//  PrimaryButtonStyle.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Self.Configuration) -> some View {
        let foregroundColor = isEnabled ? Color(.systemBackground) : Color(.tertiaryLabel)
        let backgroundColor = isEnabled ? Color("blue-primary") : Color(.tertiarySystemBackground)

        return configuration.label
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .foregroundColor(foregroundColor)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.9 : 1.0))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct PrimaryButton: View {
    var body: some View {
        Button {} label: {
            HStack {
                Image(systemName: "house.fill")
                Text("Label")
            }
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

#Preview {
    ZStack {
        Color(.secondarySystemBackground)
        PrimaryButton()
    }
}
