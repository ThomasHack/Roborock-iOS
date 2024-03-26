//
//  Main.swift
//  Roborock tvOS App
//
//  Created by Hack, Thomas on 30.11.23.
//

import ComposableArchitecture
import Foundation
import RoborockApi

@Reducer
struct Main {
    struct State: Equatable {
        var host: String? {
            didSet {
                UserDefaultsHelper.setHost(host)
            }
        }
        var connectivityState: ConnectivityState = .disconnected
        var segments: Segments?
        var fanspeeds = Fanspeed.allCases
        var showSettings = false
        var showRoomSelection = false

        var _apiState: Api.State?
        var apiState: Api.State {
            get {
                if var tempState = _apiState {
                    tempState.host = host
                    tempState.connectivityState = connectivityState
                    tempState.segments = segments
                    return tempState
                }
                return Api.State(
                    host: host,
                    connectivityState: connectivityState,
                    segments: segments
                )
            }
            set {
                _apiState = newValue
                segments = newValue.segments
                connectivityState = newValue.connectivityState
            }
        }

        var _settingsState: Settings.State?
        var settingsState: Settings.State {
            get {
                if var tempState = _settingsState {
                    tempState.host = host
                    tempState.connectivityState = connectivityState
                    return tempState
                }
                return Settings.State(
                    host: host,
                    hostInput: host ?? ""
                )
            }
            set {
                _settingsState = newValue
                host = newValue.host
            }
        }
    }
    @CasePathable
    enum Action {
        case toggleSettings(Bool)
        case toggleRoomSelection(Bool)
        case connectButtonTapped
        case fetchSegments
        case startCleaning
        case stopCleaning
        case pauseCleaning
        case driveHome
        case selectAll
        case none

        case apiAction(Api.Action)
        case settingsAction(Settings.Action)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .connectButtonTapped:
                switch state.apiState.connectivityState {
                case .connected, .connecting:
                    state.showSettings = false
                    return .send(.apiAction(.disconnectWebsocket))

                case .disconnected:
                    guard state.host != nil else { return .none }
                    state.showSettings = false
                    return .send(.apiAction(.connectRest))
                }

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
                if state.apiState.rooms.isEmpty {
                    guard let segments = state.apiState.segments else { return .none }
                    let rooms = segments.data.map { $0.id }
                    state.apiState.rooms = rooms
                    return .none
                }
                state.apiState.rooms = []
                return .none

            case .toggleSettings(let toggle):
                state.showSettings = toggle

            case .toggleRoomSelection(let toggle):
                state.showRoomSelection = toggle

            case .apiAction, .settingsAction:
                break
            case .none:
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
        host: UserDefaultsHelper.host
    )

    static let previewState = State(
        host: "roborock.friday.home",
        connectivityState: .connected,
        _apiState: Api.previewState,
        _settingsState: Settings.initialState
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
