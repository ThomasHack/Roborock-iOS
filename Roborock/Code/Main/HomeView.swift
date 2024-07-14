//
//  HomeView.swift
//  Roborock
//
//  Created by Hack, Thomas on 11.03.24.
//

import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    @Bindable var store: StoreOf<Main>

    var body: some View {
        ZStack(alignment: .center) {
            BackgroundView()
            if store.connectivityState == .disconnected {
                DisconnectedView(store: store)
            } else if store.connectivityState == .connecting {
                ConnectingView()
            } else if store.connectivityState == .connected {
                ConnectedView(store: store)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .alert($store.scope(state: \.apiState.alert, action: \.apiAction.alert))
        .sheet(isPresented: $store.showSettings) {
            SettingsView(store: Main.store.settings)
        }
    }
}

#Preview {
    HomeView(store: Main.previewStore)
}
