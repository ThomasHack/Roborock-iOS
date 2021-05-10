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
    var store: Store<Main.State, Main.Action> = Main.store
    
    var body: some Scene {
        WindowGroup {
            MainView(store: store)
        }
    }
}
