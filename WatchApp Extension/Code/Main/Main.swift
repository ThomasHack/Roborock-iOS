//
//  Main.swift
//  WatchApp Extension
//
//  Created by Thomas Hack on 17.07.21.
//

import ComposableArchitecture
import Foundation
import RoborockApi

struct WatchKitId: Hashable {}

struct Main: ReducerProtocol {
    struct State: Equatable {
        var _homeState: Home.State?
        var homeState: Home.State {
            get {
                if var tempState = _homeState {
                    tempState.apiState = apiState
                    tempState.sharedState = sharedState
                    return tempState
                }
                return Home.State(
                    apiState: apiState,
                    sharedState: sharedState
                )
            }
            set {
                _homeState = newValue
            }
        }

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

        var _watchConnectionState: WatchConnection.State?
        var watchConnectionState: WatchConnection.State {
            get {
                if var tempState = _watchConnectionState {
                    tempState.sharedState = sharedState
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
    }

    enum Action {
        case home(Home.Action)
        case api(Api.Action)
        case shared(Shared.Action)
        case watchConnection(WatchConnection.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .home, . api, .shared, .watchConnection:
                break
            }
            return .none
        }
        Scope(state: \.apiState, action: /Action.api) {
            Api()
        }
        Scope(state: \.sharedState, action: /Action.shared) {
            Shared()
        }
        Scope(state: \.homeState, action: /Action.home) {
            Home()
        }
        Scope(state: \.watchConnectionState, action: /Action.watchConnection) {
            WatchConnection()
        }
    }

    static let store = Store(
        initialState: State(
            _homeState: Home.initialState,
            _apiState: Api.initialState,
            _sharedState: Shared.initialState,
            _watchConnectionState: WatchConnection.initialState

        ),
        reducer: Main()
    )
}

extension Store where State == Main.State, Action == Main.Action {
    var home: Store<Home.State, Home.Action> {
        scope(state: \.homeState, action: Main.Action.home)
    }

    var api: Store<Api.State, Api.Action> {
        scope(state: \.apiState, action: Main.Action.api)
    }

    var watchConnection: Store<WatchConnection.State, WatchConnection.Action> {
        scope(state: \.watchConnectionState, action: Main.Action.watchConnection)
    }
}
