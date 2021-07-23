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
    var store: Store<Main.State, Main.Action> = Main.store

    @SceneBuilder var body: some Scene {
        WindowGroup {
            MainView(store: self.store)
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
