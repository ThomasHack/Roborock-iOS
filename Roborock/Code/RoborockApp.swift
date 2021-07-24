//
//  RoborockApp.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import SwiftUI
import WatchConnectivity

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let viewStore = ViewStore(Main.store)
        viewStore.send(.watchConnection(.connect))
        return true
    }
}

@main
struct RoborockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegat
    @Environment(\.scenePhase) var scenePhase

    var store: Store<Main.State, Main.Action> = Main.store

    @SceneBuilder
    var body: some Scene {
        WindowGroup {
            MainView(store: store)
        }
        .onChange(of: scenePhase) { phase in
            handlePhaseChange(phase)
        }
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
        let viewStore = ViewStore(store)
        guard let host = viewStore.state.shared.host, let url = URL(string: host) else { return }
        viewStore.send(.api(.connect(url)))
        viewStore.send(.watchConnection(.connect))
    }

    private func disconnect() {
        ViewStore(store).send(.api(.disconnect))
    }
}
