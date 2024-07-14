//
//  MainView.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 30.11.23.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    @Bindable var store: StoreOf<Main>

    var body: some View {
        if store.connectivityState == .disconnected {
            DisconnectedView(store: store)
        } else if store.connectivityState == .connecting {
            ConnectingView()
        } else if store.connectivityState == .connected {
            ConnectedView(store: store)
        }
    }
}

#Preview {
    TabView(selection: .constant(1)) {
        ZStack {
            GradientBackgroundView()
                .edgesIgnoringSafeArea(.all)

            MainView(store: Main.previewStore)
        }
        .tabItem {
            Image(systemName: "house")
            Text("Home")
        }
        .tag(1)
        .toolbarBackground(Color("blue-light"), for: .tabBar)

        Text("")
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(1)
    }
}
