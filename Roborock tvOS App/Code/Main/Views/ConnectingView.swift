//
//  DisconnectedView.swift
//  Roborock
//
//  Created by Hack, Thomas on 02.04.24.
//

import ComposableArchitecture
import SwiftUI

struct ConnectingView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 40) {
            Text("Connecting to the robot.")
                .foregroundStyle(Color("textColorDark"))
            ProgressView()
        }
    }
}

#Preview {
    ConnectingView()
}
