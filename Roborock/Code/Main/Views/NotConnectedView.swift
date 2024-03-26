//
//  NotConnectedView.swift
//  Roborock
//
//  Created by Hack, Thomas on 10.05.21.
//

import ComposableArchitecture
import SwiftUI

struct NotConnectedView: View {
    @Bindable var store: StoreOf<Main>

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            HStack {
                Text("api.disconnected")
            }
            .foregroundColor(.secondary)

            Button {
                if store.host != nil {
                    store.send(.toggleSettings(true))
                } else {
                    store.send(.toggleSettings(true))
                }
            } label: {
                HStack {
                    Image(systemName: "bolt.fill")
                    Text((store.host ?? "").isEmpty ? "home.setHost" : "api.connect")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            Spacer()
        }
    }
}

#Preview {
    NotConnectedView(store: Main.previewStore)
}
