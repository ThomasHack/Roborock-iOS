//
//  NotConnectedView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import SwiftUI

struct NotConnectedView: View {
    let store: Store<Main.State, Main.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .center, spacing: 8) {
                HStack {
                    Image(systemName: "bolt.slash.fill")
                    Text("api.disconnected")
                }.foregroundColor(.secondary)
                Button {
                    if viewStore.sharedState.host != nil {
                        viewStore.send(.toggleSettings(true))
                    } else {
                        viewStore.send(.toggleSettings(true))
                    }
                } label: {
                    Text((viewStore.sharedState.host ?? "").isEmpty ? "home.setHost" : "api.connect")
                }
            }
        }
    }
}

struct NotConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        NotConnectedView(store: Main.previewStore)
    }
}
