//
//  SecondaryButtonStyle.swift
//  Roborock
//
//  Created by Hack, Thomas on 12.07.21.
//

import SwiftUI

struct SecondaryRoundedButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Self.Configuration) -> some View {
        let foregroundColor = isEnabled ? Color("blue-primary") : Color(.tertiaryLabel)
        let backgroundColor = isEnabled ? Color(.systemBackground) : Color(.tertiarySystemBackground)

        return configuration.label
            .padding(16)
            .foregroundColor(foregroundColor.opacity(configuration.isPressed ? 0.9 : 1.0))
            .background(backgroundColor)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct SecondaryRoundedButton: View {
    var body: some View {
        Button {} label: {
            Image(systemName: "house.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
        }
        .buttonStyle(SecondaryRoundedButtonStyle())
    }
}

#Preview {
    VStack {
        SecondaryRoundedButton()
    }
    .padding(.vertical, 100)
    .padding(.horizontal, 100)
    .background(Color(UIColor.secondarySystemBackground))
    .previewLayout(.fixed(width: 150, height: 200))
}
