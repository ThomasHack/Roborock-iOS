//
//  PrimaryButtonStyle.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Self.Configuration) -> some View {
        let foregroundColor = isEnabled ? Color(.systemBackground) : Color(.tertiaryLabel)
        let backgroundColor = isEnabled ? Color("primary") : Color(.tertiarySystemBackground)

        return configuration.label
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
            Image(systemName: "house.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PrimaryButton()
        }
        .padding(.vertical, 100)
        .padding(.horizontal, 100)
        .background(Color(UIColor.secondarySystemBackground))
        .previewLayout(.fixed(width: 150, height: 200))
    }
}
