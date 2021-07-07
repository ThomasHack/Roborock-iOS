//
//  NotConnectedView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import SwiftUI
import ComposableArchitecture

struct NotConnectedView: View {
    let store: Store<Home.HomeFeatureState, Home.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .center, spacing: 8) {
                HStack() {
                    Image(systemName: "bolt.slash.fill")
                    Text("api.disconnected")
                }.foregroundColor(.secondary)
                Button(action: {
                    if viewStore.shared.host != nil {
                        viewStore.send(.settingsButtonTapped)
                    } else {
                        viewStore.send(.settingsButtonTapped)
                    }
                }) {
                    Text((viewStore.shared.host ?? "").isEmpty ? "home.setHost" : "api.connect")
                }
            }
        }
    }
}

struct NotConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        NotConnectedView(store: Main.previewStoreHome)
    }
}
