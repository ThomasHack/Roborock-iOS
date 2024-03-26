//
//  HeaderView.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 30.11.23.
//

import ComposableArchitecture
import SwiftUI

struct HeaderView: View {
    let store: StoreOf<Main>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            HStack(spacing: 16) {
                Text("home.status")
                if let state = viewStore.apiState.status?.state {
                    Text(LocalizedStringKey(String("roborock.state.\(state)")))
                        .bold()
                } else {
                    Text(viewStore.connectivityState == .connected ? "api.connected" : "api.disconnected")
                        .bold()
                }
            }
        })
    }
}

#Preview {
    HeaderView(store: Main.previewStore)
}
