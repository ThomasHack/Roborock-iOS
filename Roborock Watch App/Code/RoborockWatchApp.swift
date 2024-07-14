//
//  RoborockWatchApp.swift
//  Roborock Watch App
//
//  Created by Hack, Thomas on 27.11.23.
//

import ComposableArchitecture
import SwiftUI

@main
struct RoborockWatchApp: App {
    @Environment(\.scenePhase) var scenePhase

    var store: StoreOf<Main> = Main.store

    @SceneBuilder
    var body: some Scene {
        WindowGroup {
            MainView(store: self.store)
                .onAppear {
                    requestSettings()
                }
                .onChange(of: scenePhase, { _, newValue in
                    handlePhaseChange(newValue)
                })
        }
//        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
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
        store.send(.api(.connect))
    }

    private func disconnect() {
        store.send(.api(.disconnect))
    }

    private func requestSettings() {
        Main.store.watchKitSession.send(.connect)
    }
}
