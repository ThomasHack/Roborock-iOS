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

    let store: StoreOf<Main> = Main.store

    @SceneBuilder
    var body: some Scene {
        WindowGroup {
            MainView(store: store)
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
        store.send(.connect)
    }

    private func disconnect() {
        store.send(.disconnect)
    }
}

 class AppDelegate: NSObject, UIApplicationDelegate {
    @Dependency(\.watchkitSessionClient) var watchKitSessionClient

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Main.store.watchKitSession.send(.connect)
        return true
    }
 }
