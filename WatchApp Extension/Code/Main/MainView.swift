//
//  MainView.swift
//  WatchApp Extension
//
//  Created by Thomas Hack on 17.07.21.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase

    var store: Store<Main.State, Main.Action>

    private func connect() {
        let viewStore = ViewStore(store)
        guard let host = viewStore.shared.host, let url = URL(string: host) else { return }
        viewStore.send(.api(.connect(url)))
    }

    private func disconnect() {
        ViewStore(store).send(.api(.disconnect))
    }

    private func requestSettings() {
        let viewStore = ViewStore(store)
        viewStore.send(.connect)
    }

    private func handlePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            connect()
        case .inactive:
            break
        case .background:
            disconnect()
        default:
            break
        }
    }

    var body: some View {
        WithViewStore(self.store) { viewStore in
            if viewStore.shared.host != nil {
                HomeView(store: Main.store.home)
            }
        }
        .onAppear {
            let viewStore = ViewStore(store)
            if viewStore.shared.host != nil {
                connect()
            } else {
                requestSettings()
            }
        }
        .onChange(of: scenePhase) { phase in
            // Handle connect/reconnect when entering foreground/background
            handlePhaseChange(phase)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Main.store)
    }
}
