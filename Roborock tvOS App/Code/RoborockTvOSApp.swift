//
//  RoborockTvOSApp.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 30.11.23.
//

import ComposableArchitecture
import SwiftUI

@main
struct RoborockTvOSApp: App {
    @Environment(\.scenePhase) var scenePhase

    @Bindable var store: StoreOf<Main> = Main.store

    @SceneBuilder
    var body: some Scene {
        WindowGroup {
            ZStack {
                GradientBackgroundView()
                    .edgesIgnoringSafeArea(.all)

                TabView(selection: $store.selection, content: {
                    MainView(store: store)
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }
                        .tag(TabSelection.home)
                        .toolbarBackground(Color("blue-light"), for: .tabBar)

                    SettingsView(store: store.settings)
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                        .tag(TabSelection.settings)
                        .toolbarBackground(Color("blue-light"), for: .tabBar)
                })
            }
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
        store.send(.apiAction(.connect))
    }

    private func disconnect() {
        store.send(.apiAction(.disconnect))
    }
}
