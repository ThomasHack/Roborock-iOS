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
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack(alignment: .center) {
                Spacer()
                HStack {
                    Text("api.disconnected")
                }
                .foregroundColor(.secondary)

                Button {
                    if viewStore.host != nil {
                        viewStore.send(.toggleSettings(true))
                    } else {
                        viewStore.send(.toggleSettings(true))
                    }
                } label: {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text((viewStore.host ?? "").isEmpty ? "home.setHost" : "api.connect")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                Spacer()
            }
        })
    }
}

struct NotConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        NotConnectedView(store: Main.previewStore)
    }
}
