//
//  RoborockApp.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 13.07.21.
//

import ComposableArchitecture
import SwiftUI

@main
struct RoborockApp: App {
    @Environment(\.scenePhase) var scenePhase

    var store: Store<Main.State, Main.Action> = Main.store

    private func connect() {
        let viewStore = ViewStore(store)
        guard // let host = viewStore.state.shared.host,
                let url = URL(string: "ws://roborock") else { return }
        viewStore.send(.api(.connect(url)))
    }

    private func disconnect() {
        ViewStore(store).send(.api(.disconnect))
    }

    private func handlePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            connect()
        case .background:
            disconnect()
        default:
            break
        }
    }

    @SceneBuilder var body: some Scene {
        WindowGroup {
            MainView(store: self.store)
                .onAppear { connect() }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
