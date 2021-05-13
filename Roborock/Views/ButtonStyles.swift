//
//  ButtonStyles.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import SwiftUI
import SwiftUIVisualEffects

struct PrimaryButtonStyle: ButtonStyle {
    var active = false
    var disabled = false

    func makeBody(configuration: Self.Configuration) -> some View {
        let backgroundColor = Color("blue")
        let foregroundColor = Color(UIColor.white)

        return configuration.label
            .padding(24)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .background(BlurView().opacity(active ? 1.0 : 0.2))
            .overlay(Circle().stroke(Color("blue-light"), lineWidth: 2))
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.125), radius: 20, x: 10, y: 10)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var active = false
    var disabled = false

    func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .padding(16)
            .foregroundColor(Color("blue"))
            .background(BlurEffect())
            .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.075), radius: 15.0, x: 7.5, y: 7.5)
    }
}

struct PrimaryButton: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "house.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(PrimaryButtonStyle())

    }
}

struct SecondaryButton: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "house.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
        }
        .buttonStyle(SecondaryButtonStyle())

    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PrimaryButton()
            SecondaryButton()
        }
            .previewLayout(.fixed(width: 80, height: 160))
    }
}
