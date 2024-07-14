//
//  Settings.swift
//  Roborock
//
//  Created by Hack, Thomas on 06.07.21.
//

import ComposableArchitecture
import Foundation
import RoborockApi

@Reducer
struct Settings {
    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("host")) var host = ""
        var hostInput = ""
    }

    @CasePathable
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
                UserDefaultsHelper.setHost(state.host)
            }
            return .none
        }
    }

    static let initialState = State()

    static let previewState = State(
        hostInput: "roborock.friday.home"
    )

    static let previewStore = Store(initialState: previewState) {
        Settings()
    }
}
