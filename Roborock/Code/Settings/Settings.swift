//
//  Settings.swift
//  Roborock
//
//  Created by Hack, Thomas on 06.07.21.
//

import ComposableArchitecture
import Foundation
import Intents

struct Settings: ReducerProtocol {
    struct State: Equatable {
        var hostInput: String = ""

        var apiState: Api.State
        var sharedState: Shared.State
    }

    enum Action {
        case hostInputTextChanged(String)
        case connectButtonTapped
        case doneButtonTapped
        case requestSiriAuthorization
        case donateSiriShortcut

        case api(Api.Action)
        case shared(Shared.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .hostInputTextChanged(let text):
                state.hostInput = text

            case .connectButtonTapped:
                switch state.apiState.connectivityState {
                case .connected, .connecting:
                    return EffectTask(value: Action.api(.disconnect))

                case .disconnected:
                    guard let websocketUrl = URL(string: "ws://\(state.hostInput)"),
                          let restUrl = URL(string: "http://\(state.hostInput)") else { return .none }
                    return .merge(
                        EffectTask(value: Action.api(.connect(websocketUrl))),
                        EffectTask(value: Action.api(.connectRest(restUrl)))
                    )
                }
            case .doneButtonTapped:
                state.sharedState.host = state.hostInput

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
                    return EffectTask(value: Action.donateSiriShortcut)
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
        }
    }

    static let initialState = State(
        hostInput: UserDefaults(suiteName: Shared.appGroupName)?.string(forKey: Shared.hostDefaultsKeyName) ?? "",
        apiState: Api.initialState,
        sharedState: Shared.initialState
    )

    static let previewState = State(
        hostInput: "roborock.friday.home",
        apiState: Api.previewState,
        sharedState: Shared.previewState
    )

    static let previewStore = Store(
        initialState: previewState,
        reducer: Settings()
    )
}
