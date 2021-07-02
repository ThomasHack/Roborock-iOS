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
        let background = LinearGradient(gradient: Gradient(
            colors: [Color("blue"), Color("blue-dark")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
        
        let foregroundColor = Color(.systemBackground)

        return configuration.label
            .padding(24)
            .foregroundColor(foregroundColor)
            .background(background)
            .clipShape(Circle())
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var active = false
    var disabled = false

    func makeBody(configuration: Self.Configuration) -> some View {
        let background = LinearGradient(gradient: Gradient(
            colors: [Color(.systemBackground), Color("blue")]),
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing).opacity(0.05)
        return configuration.label
            .padding(16)
            .foregroundColor(Color("blue"))
            .background(background)
            .background(Color(.systemBackground))
            .clipShape(Circle())
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
            Spacer(minLength: 40)
            SecondaryButton()
        }
        .padding(.vertical, 100)
        .padding(.horizontal, 100)
        .background(Color(UIColor.secondarySystemBackground))
        .previewLayout(.fixed(width: 150, height: 200))
    }
}
