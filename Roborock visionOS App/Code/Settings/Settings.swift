//
//  Settings.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 30.11.23.
//

import ComposableArchitecture
import Foundation
import RoborockApi

@Reducer
struct Settings {
    struct State: Equatable {
        var host: String?
        var connectivityState: ConnectivityState = .disconnected
        @BindingState var hostInput = ""
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case doneButtonTapped
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                break
            case .doneButtonTapped:
                state.host = state.hostInput
            }
            return .none
        }
    }

    static let initialState = State(
        hostInput: UserDefaultsHelper.host ?? ""
    )

    static let previewState = State(
        connectivityState: .disconnected,
        hostInput: "roborock.friday.home"
    )

    static let previewStore = Store(initialState: previewState) {
        Settings()
    }
}
