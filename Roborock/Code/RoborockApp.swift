//
//  RoborockApp.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import SwiftUI
import WatchConnectivity

@main
struct RoborockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
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
        ViewStore(store, observe: { $0 }).send(.apiAction(.connectRest))
    }

    private func disconnect() {
        ViewStore(store, observe: { $0 }).send(.apiAction(.disconnectWebsocket))
    }
}

 class AppDelegate: NSObject, UIApplicationDelegate {
    @Dependency(\.watchkitSessionClient) var watchKitSessionClient

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        ViewStore(Main.store.watchKitSession, observe: { $0 }).send(.connect)
        return true
    }
 }
