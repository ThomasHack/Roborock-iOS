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
        let backgroundColor = isEnabled ? Color("primary") : Color.black

        return configuration.label
            .fixedSize(horizontal: true, vertical: false)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(22.0)
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
        }
        .previewLayout(.fixed(width: 224, height: 184))
    }
}
