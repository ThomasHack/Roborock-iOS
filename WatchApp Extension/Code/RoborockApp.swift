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

    @SceneBuilder
    var body: some Scene {
        WindowGroup {
            MainView(store: self.store)
                .onAppear {
                    requestSettings()
                }
                .onChange(of: scenePhase) { phase in
                    handlePhaseChange(phase)
                }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
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
        ViewStore(store).send(.api(.connectRest))
    }

    private func disconnect() {
        ViewStore(store).send(.api(.disconnect))
    }

    private func requestSettings() {
        ViewStore(store).send(.watchConnection(.connect))
    }
}
