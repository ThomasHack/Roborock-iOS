//
//  BackgroundView.swift
//  Roborock
//
//  Created by Hack, Thomas on 02.04.24.
//

import SwiftUI

struct BackgroundView: View {
    let gradient = Gradient(colors: [Color("blue-light"), Color("blue-dark")])

    var body: some View {
        LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    BackgroundView()
}
