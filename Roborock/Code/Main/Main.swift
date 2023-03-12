//
//  Main.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import Foundation
import RoborockApi

struct WatchKitId: Hashable {}

struct Main: ReducerProtocol {
    struct State: Equatable {
        var showSettings = false
        var showRoomSelection = false

        var _apiState: Api.State?
        var apiState: Api.State {
            get {
                if let tempState = _apiState {
                    return tempState
                }
                return Api.initialState
            }
            set {
                _apiState = newValue
            }
        }

        var _sharedState: Shared.State?
        var sharedState: Shared.State {
            get {
                if let tempState = _sharedState {
                    return tempState
                }
                return Shared.initialState
            }
            set {
                _sharedState = newValue
            }
        }

        var _settingsState: Settings.State?
        var settingsState: Settings.State {
            get {
                if let tempState = _settingsState {
                    return tempState
                }
                return Settings.State(
                    hostInput: sharedState.host ?? "",
                    apiState: apiState,
                    sharedState: sharedState
                )
            }
            set {
                _settingsState = newValue
            }
        }

        var _watchConnectionState: WatchConnection.State?
        var watchConnectionState: WatchConnection.State {
            get {
                if let tempState = _watchConnectionState {
                    return tempState
                }
                return WatchConnection.State(
                    sharedState: sharedState
                )
            }
            set {
                _watchConnectionState = newValue
            }
        }

        var batteryIcon: String {
            guard let status = apiState.status else { return "exclamationmark.circle" }
            if status.state == 8 { // Charging
                return "battery.100.bolt"
            } else if status.battery < 25 {
                return "battery.25"
            } else {
                return "battery.100"
            }
        }

        var fanspeeds = Fanspeed.allCases
    }

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
        case sharedAction(Shared.Action)
        case settingsAction(Settings.Action)
        case watchConnectionAction(WatchConnection.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .connectButtonTapped:
                switch state.apiState.connectivityState {
                case .connected, .connecting:
                    state.showSettings = false
                    return EffectTask(value: Action.apiAction(.disconnect))

                case .disconnected:
                    guard let websocketUrl = URL(string: "ws://\(state.settingsState.hostInput)"),
                          let restUrl = URL(string: "http://\(state.settingsState.hostInput)") else { return .none }
                    state.showSettings = false
                    return .merge(
                        EffectTask(value: Action.apiAction(.connect(websocketUrl))),
                        EffectTask(value: Action.apiAction(.connectRest(restUrl)))
                    )
                }

            case .fetchSegments:
                return EffectTask(value: Action.apiAction(.fetchSegments))

            case .startCleaning:
                return EffectTask(value: Action.apiAction(.startCleaningSegment))

            case .stopCleaning:
                return EffectTask(value: Action.apiAction(.stopCleaning))

            case .pauseCleaning:
                return EffectTask(value: Action.apiAction(.pauseCleaning))

            case .driveHome:
                return EffectTask(value: Action.apiAction(.driveHome))

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

            case .apiAction, .sharedAction, .settingsAction, .watchConnectionAction:
                break
            case .none:
                break
            }
            return .none
        }
        Scope(state: \.apiState, action: /Action.apiAction) {
            Api()
        }
        Scope(state: \.sharedState, action: /Action.sharedAction) {
            Shared()
        }
        Scope(state: \.settingsState, action: /Action.settingsAction) {
            Settings()
        }
        Scope(state: \.watchConnectionState, action: /Action.watchConnectionAction) {
            WatchConnection()
        }
    }

    static let initialState = State(
        _apiState: Api.initialState,
        _sharedState: Shared.initialState,
        _settingsState: Settings.initialState,
        _watchConnectionState: WatchConnection.initialState
    )

    static let previewState = State(
        _apiState: Api.previewState,
        _sharedState: Shared.previewState,
        _settingsState: Settings.initialState,
        _watchConnectionState: WatchConnection.initialState
    )

    static let previewStore = Store(
        initialState: previewState,
        reducer: Main()
    )

    static let store = Store<Main.State, Main.Action>(
        initialState: initialState,
        reducer: Main()
    )
}

extension Store where State == Main.State, Action == Main.Action {
    var settings: Store<Settings.State, Settings.Action> {
        scope(state: \.settingsState, action: Main.Action.settingsAction)
    }

    var api: Store<Api.State, Api.Action> {
        scope(state: \.apiState, action: Main.Action.apiAction)
    }

    var shared: Store<Shared.State, Shared.Action> {
        scope(state: \.sharedState, action: Main.Action.sharedAction)
    }

    var watchConnection: Store<WatchConnection.State, WatchConnection.Action> {
        scope(state: \.watchConnectionState, action: Main.Action.watchConnectionAction)
    }
}
