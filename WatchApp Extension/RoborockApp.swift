//
//  RoborockApp.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 13.07.21.
//

import SwiftUI

@main
struct RoborockApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                TabView {
                    HomeView(store: Home.store)
                    SegmentsView(store: Home.store)
                }
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
