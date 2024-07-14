//
//  Main.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 30.11.23.
//

import ComposableArchitecture
import Foundation
import RoborockApi

enum TabSelection {
    case home, settings
}

@Reducer
struct Main {
    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("host")) var host = ""
        @Shared(.inMemory("connectivityState")) var connectivityState: ConnectivityState = .disconnected
        // TODO: Check if needed
        // @Shared(.inMemory("showSettings")) var showSettings = false
        @Shared(.inMemory("showRoomSelection")) var showRoomSelection = false

        var selectedSegments: [Segment] = []
        var fanSpeedPresets = FanSpeedControlPreset.allCases
        var isMapLoading = true
        var selection: TabSelection = .home

        var apiState: Api.State
        var settingsState: Settings.State
    }

    @CasePathable
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case connect
        case disconnect
        case showSettings
        case toggleRoomSelection(Bool)
        case fetchSegments
        case startCleaning
        case stopCleaning
        case pauseCleaning
        case driveHome
        case selectAll

        case apiAction(Api.Action)
        case settingsAction(Settings.Action)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .connect:
                return .send(.apiAction(.connect))
            case .disconnect:
                return .send(.apiAction(.disconnect))
            case .fetchSegments:
                return .send(.apiAction(.fetchSegments))

            case .startCleaning:
                return .send(.apiAction(.startCleaningSegment))

            case .stopCleaning:
                return .send(.apiAction(.stopCleaning))

            case .pauseCleaning:
                return .send(.apiAction(.pauseCleaning))

            case .driveHome:
                return .send(.apiAction(.driveHome))

            case .selectAll:
                if state.apiState.selectedSegments.isEmpty {
                    state.apiState.selectedSegments = state.apiState.segments
                    return .none
                }
                state.apiState.selectedSegments = []

            case .showSettings:
                state.selection = .settings

            case let .toggleRoomSelection(toggle):
                state.showRoomSelection = toggle

            case .apiAction, .settingsAction, .binding:
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
    }

    static let initialState = State(
        apiState: Api.initialState,
        settingsState: Settings.initialState
    )

    static let previewState = State(
        apiState: Api.previewState,
        settingsState: Settings.previewState
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
}
