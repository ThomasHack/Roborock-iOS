//
//  Settings.swift
//  Roborock
//
//  Created by Hack, Thomas on 06.07.21.
//

import ComposableArchitecture
import Foundation
import Intents

enum Settings {
    struct State: Equatable {
        var hostInput: String = ""
    }

    enum Action {
        case hostInputTextChanged(String)
        case hideSettingsModal
        case connectButtonTapped
        case doneButtonTapped
        case requestSiriAuthorization
        case donateSiriShortcut

        case api(Api.Action)
        case shared(Shared.Action)
    }

    typealias Environment = Main.Environment

    static let reducer = Reducer<SettingsFeatureState, Action, Environment>.combine(
        Reducer { state, action, _ in
            switch action {
            case .hostInputTextChanged(let text):
                state.hostInput = text
            case .hideSettingsModal:
                state.showSettingsModal = false
            case .connectButtonTapped:
                switch state.connectivityState {
                case .connected, .connecting:
                    state.showSettingsModal = false
                    return Effect(value: Action.api(.disconnect))

                case .disconnected:
                    guard let url = URL(string: state.hostInput) else { return .none }
                    return .merge(
                        Effect(value: Action.api(.connect(url))),
                        Effect(value: Action.hideSettingsModal)
                    )
                }
            case .doneButtonTapped:
                state.shared.host = state.hostInput
                return Effect(value: .hideSettingsModal)

            case .requestSiriAuthorization:
                var request = false
                INPreferences.requestSiriAuthorization({status in
                    switch status {
                    case .notDetermined:
                        print("not determined")
                    case .restricted:
                        print("restricted")
                    case .denied:
                        print("denied")
                    case .authorized:
                        request = true
                    @unknown default:
                        fatalError("Unknown Siri authorization state.")
                    }
                })
                if request {
                    return Effect(value: Action.donateSiriShortcut)
                }

            case .donateSiriShortcut:
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

            case .shared, .api:
                break
            }
            return .none
        },
        Shared.reducer.pullback(
            state: \SettingsFeatureState.shared,
            action: /Action.shared,
            environment: { $0 }
        ),
        Api.reducer.pullback(
            state: \SettingsFeatureState.api,
            action: /Action.api,
            environment: { $0 }
        )
    )

    static let initialState = State(
        hostInput: UserDefaults(suiteName: Shared.appGroupName)?.string(forKey: Shared.hostDefaultsKeyName) ?? ""
    )
}
