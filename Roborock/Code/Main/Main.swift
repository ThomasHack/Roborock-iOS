//
//  Main.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import Foundation
import RoborockApi
import UIKit

struct WatchKitId: Hashable {}

@Reducer
struct Main {
    @Dependency(\.restClient) var restClient
    @Dependency(\.valetudoMapParser) var vatudoMapParser

    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("host")) var host = ""
        @Shared(.inMemory("connectivityState")) var connectivityState: ConnectivityState = .disconnected
        @Shared(.inMemory("showSettings")) var showSettings = false
        @Shared(.inMemory("showRoomSelection")) var showRoomSelection = false

        var apiState: Api.State
        var settingsState: Settings.State
        var watchKitSession: WatchKitSession.State
    }

    @CasePathable
    enum Action: BindableAction {
        case connect
        case disconnect
        case selectAll
        case toggleSettings(Bool)
        case toggleRoomSelection(Bool)
        case apiAction(Api.Action)
        case settingsAction(Settings.Action)
        case watchKitSession(WatchKitSession.Action)
        case binding(BindingAction<State>)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .connect:
                return .send(.apiAction(.connect))
            case .disconnect:
                return .send(.apiAction(.disconnect))
            case .selectAll:
                if state.apiState.selectedSegments.isEmpty {
                    state.apiState.selectedSegments = state.apiState.segments
                    return .none
                }
                state.apiState.selectedSegments = []
            case .toggleSettings(let toggle):
                state.showSettings = toggle
            case .toggleRoomSelection(let toggle):
                state.showRoomSelection = toggle
            case .apiAction, .settingsAction, .watchKitSession, .binding:
                break
            }
            return .none
        }
        Scope(state: \.apiState, action: \.apiAction) {
            Api()
        }
        Scope(state: \.settingsState, action: \.settingsAction) {
            Settings()
        }
        Scope(state: \.watchKitSession, action: \.watchKitSession) {
            WatchKitSession()
        }
    }

    static let initialState = State(
        apiState: Api.initialState,
        settingsState: Settings.initialState,
        watchKitSession: WatchKitSession.initialState
    )

    static let previewState = State(
        apiState: Api.previewState,
        settingsState: Settings.previewState,
        watchKitSession: WatchKitSession.previewState
    )

    static let previewStore = Store(initialState: previewState) {
        Main()
    }

    static let store = Store(initialState: initialState) {
        Main()
    }
}

extension Store where State == Main.State, Action == Main.Action {
    var settings: Store<Settings.State, Settings.Action> {
        scope(state: \.settingsState, action: \.settingsAction)
    }

    var api: Store<Api.State, Api.Action> {
        scope(state: \.apiState, action: \.apiAction)
    }

    var watchKitSession: Store<WatchKitSession.State, WatchKitSession.Action> {
        scope(state: \.watchKitSession, action: \.watchKitSession)
    }
}
