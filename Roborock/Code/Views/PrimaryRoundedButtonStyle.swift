//
//  PrimaryButtonStyle.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import SwiftUI

struct PrimaryRoundedButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Self.Configuration) -> some View {
        let foregroundColor = isEnabled ? Color(.systemBackground) : Color(.tertiaryLabel)
        let backgroundColor = isEnabled ? Color("blue-primary") : Color(.tertiarySystemBackground)

        return configuration.label
            .padding(24)
            .foregroundColor(foregroundColor)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.9 : 1.0))
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct PrimaryRoundedButton: View {
    var body: some View {
        Button {} label: {
            Image(systemName: "house.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(PrimaryRoundedButtonStyle())
    }
}

struct PrimaryRoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground)
            PrimaryRoundedButton()
        }
    }
}
