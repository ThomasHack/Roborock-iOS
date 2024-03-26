//
//  PrimaryButtonStyle.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 01.12.23.
//

import SwiftUI

struct PrimaryRoundedButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Self.Configuration) -> some View {
        let foregroundColor = isEnabled ? Color("systemBackground") : Color("tertiaryLabel")
        let backgroundColor = isEnabled ? Color("blue-primary") : Color("tertiarySystemBackground")

        return configuration.label
            .font(.headline)
            .padding(24)
            .foregroundColor(foregroundColor)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.9 : 1.0))
            .clipShape(Circle())
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
        .buttonStyle(PrimaryRoundedButtonStyle())
    }
}

#Preview {
    ZStack {
        Color(.secondarySystemBackground)
        PrimaryButton()
    }
}
