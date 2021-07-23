//
//  RoborockApp.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import Intents
import SwiftUI

@main
struct RoborockApp: App {
    @Environment(\.scenePhase) var scenePhase

    var store: Store<Main.State, Main.Action> = Main.store

    private func connect() {
        let viewStore = ViewStore(store)
        guard let host = viewStore.state.shared.host, let url = URL(string: host) else { return }
        viewStore.send(.api(.connect(url)))
    }

    private func disconnect() {
        ViewStore(store).send(.api(.disconnect))
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

    private func handleSiriAuthorization() {
        INPreferences.requestSiriAuthorization({status in
            switch status {
            case .notDetermined:
                print("not determined")
            case .restricted:
                print("restricted")
            case .denied:
                print("denied")
            case .authorized:
                donateShortcut()
            @unknown default:
                fatalError("Unknown Siri authorization state.")
            }
        })
    }

    private func donateShortcut() {
        let intent = CleanRoomIntent()
        intent.suggestedInvocationPhrase = "Staubsaugen starten"
        intent.rooms = [Room(identifier: "17", display: "Wohnzimmer")]
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                print("Interaction donation failed: \(error.localizedDescription)")
                return
            }
            print("Successfully donated interaction")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView(store: store)
                .onAppear {
                    let viewStore = ViewStore(self.store)
                    viewStore.send(.connect)
                }
        }
        .onChange(of: scenePhase) { phase in
            handlePhaseChange(phase)
            handleSiriAuthorization()
        }
    }
}
