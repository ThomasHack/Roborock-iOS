//
//  MainView.swift
//  WatchApp Extension
//
//  Created by Thomas Hack on 17.07.21.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {

    var store: Store<Main.State, Main.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            if !(viewStore.sharedState.host ?? "").isEmpty {
                HomeView(store: Main.store.home)
                    .onAppear {
                        connect()
                    }
            } else {
                VStack(spacing: 0) {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
    }

    private func connect() {
        let viewStore = ViewStore(store)
        guard let host = viewStore.sharedState.host,
              let websocketUrl = URL(string: "ws://\(host)"),
              let restUrl = URL(string: "http://\(host)") else { return }
        viewStore.send(.api(.connect(websocketUrl)))
        viewStore.send(.api(.connectRest(restUrl)))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Main.store)
    }
}
