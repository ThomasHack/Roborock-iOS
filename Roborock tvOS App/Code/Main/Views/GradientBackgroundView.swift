//
//  GradientBackgroundView.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 14.12.23.
//

import SwiftUI

struct GradientBackgroundView: View {
    let gradient = Gradient(colors: [Color("blue-light"), Color("blue-dark")])

    var body: some View {
        LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
    }
}

#Preview {
    GradientBackgroundView()
}
