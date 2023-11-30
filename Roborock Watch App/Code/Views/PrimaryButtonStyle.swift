//
//  PrimaryButtonStyle.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 19.07.21.
//

import SwiftUI
import UIKit

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Self.Configuration) -> some View {
        let foregroundColor = isEnabled ? Color.white : Color.gray
        let backgroundColor = isEnabled ? Color("blue-primary") : Color("secondaryBackground")

        return configuration.label
            .fixedSize(horizontal: true, vertical: false)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .foregroundColor(foregroundColor)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.9 : 1.0))
            .cornerRadius(22.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct PrimaryButton: View {
    var body: some View {
        Button {} label: {
            Text("Test 123")
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PrimaryButton()
                .disabled(false)
        }
        .previewLayout(.fixed(width: 224, height: 184))
    }
}
