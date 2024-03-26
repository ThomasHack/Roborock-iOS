//
//  RoborockVisionOSApp.swift
//  Roborock visionOS App
//
//  Created by Hack, Thomas on 14.12.23.
//

import ComposableArchitecture
import SwiftUI

@main
struct RoborockVisionOSApp: App {
    @Environment(\.scenePhase) var scenePhase

    let store: StoreOf<Main> = Main.store

    @State var selection = 1

    @SceneBuilder
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selection, content: {
                MainView(store: store)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(1)
                SettingsView(store: store.settings)
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag(2)
            })
        }
        .onChange(of: scenePhase, { _, newValue in
            handlePhaseChange(newValue)
        })
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

    private func connect() {
        ViewStore(store, observe: { $0 }).send(.apiAction(.connectRest))
    }

    private func disconnect() {
        ViewStore(store, observe: { $0 }).send(.apiAction(.disconnectWebsocket))
    }
}
