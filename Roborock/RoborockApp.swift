//
//  RoborockApp.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import SwiftUI
import ComposableArchitecture

@main
struct RoborockApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    var store: Store<Main.State, Main.Action> = Main.store
    
    fileprivate func connect() {
        let viewStore = ViewStore(store)
        guard let url = URL(string: "ws://roborock") else { return }
        viewStore.send(.api(.connect(url)))
    }

    fileprivate func disconnect() {
        ViewStore(store).send(.api(.disconnect))
    }
    
    var body: some Scene {
        WindowGroup {
            MainView(store: store)
        }
        .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        print("sceneDidChange: active")
                        connect()
                    case .background:
                        print("sceneDidChange: background")
                        disconnect()
                    default:
                        break
                    }
                }
    }
}
