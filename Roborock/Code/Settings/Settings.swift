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
        var host: String?
        var hostInput: String = ""

        var apiState: Api.State
    }

    enum Action {
        case hostInputTextChanged(String)
        case connectButtonTapped
        case doneButtonTapped
        case requestSiriAuthorization
        case donateSiriShortcut
        case api(Api.Action)
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
                    return EffectTask(value: Action.api(.connectRest))
                }
            case .doneButtonTapped:
                state.host = state.hostInput

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

            case .api:
                break
            }
            return .none
        }
    }

    static let initialState = State(
        hostInput: UserDefaultsHelper.host ?? "",
        apiState: Api.initialState
    )

    static let previewState = State(
        hostInput: "roborock.friday.home",
        apiState: Api.previewState
    )

    static let previewStore = Store(
        initialState: previewState,
        reducer: Settings()
    )
}
