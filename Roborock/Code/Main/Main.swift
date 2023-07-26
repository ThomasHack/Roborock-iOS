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
        var host: String? {
            didSet {
                UserDefaultsHelper.setHost(host)
            }
        }
        var connectivityState: ConnectivityState = .disconnected
        var segments: Segments?

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
                    return tempState
                }
                return Settings.State(
                    host: host,
                    hostInput: host ?? "",
                    apiState: apiState
                )
            }
            set {
                _settingsState = newValue
                host = newValue.host
            }
        }

        var _watchConnectionState: WatchConnection.State?
        var watchConnectionState: WatchConnection.State {
            get {
                if let tempState = _watchConnectionState {
                    return tempState
                }
                return WatchConnection.State()
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
                    guard state.host != nil else { return .none }
                    state.showSettings = false
                    return EffectTask(value: Action.apiAction(.connectRest))
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

            case .apiAction, .settingsAction, .watchConnectionAction:
                break
            case .none:
                break
            }
            return .none
        }
        Scope(state: \.apiState, action: /Action.apiAction) {
            Api()
        }
        Scope(state: \.settingsState, action: /Action.settingsAction) {
            Settings()
        }
        Scope(state: \.watchConnectionState, action: /Action.watchConnectionAction) {
            WatchConnection()
        }
    }

    static let initialState = State(
        host: UserDefaultsHelper.host
    )

    static let previewState = State(
        host: "roborock.friday.home",
        _apiState: Api.previewState,
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

    var watchConnection: Store<WatchConnection.State, WatchConnection.Action> {
        scope(state: \.watchConnectionState, action: Main.Action.watchConnectionAction)
    }
}
