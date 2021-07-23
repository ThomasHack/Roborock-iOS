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

enum Main {
    struct State: Equatable {
        var home: Home.State
        var api: Api.State
        var shared: Shared.State

        var homeFeature: Home.HomeFeatureState {
            get { Home.HomeFeatureState(home: self.home, shared: self.shared, api: self.api) }
            set { self.home = newValue.home; self.shared = newValue.shared; self.api = newValue.api }
        }
    }

    enum Action {
        case connect
        case watchSessionDidActivate
        case watchSessionDidDeactivate
        case requestDataSync
        case didReceiveMessage([String: Any])

        case home(Home.Action)
        case api(Api.Action)
        case shared(Shared.Action)
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let restClient: RestClient
        let websocketClient: ApiWebSocketClient
        let watchkitSessionClient: WatchKitSessionClient
    }

    static let initialEnvironment = Environment(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        restClient: RestClient(baseUrl: "http://roborock/api/"),
        websocketClient: ApiWebSocketClient.live,
        watchkitSessionClient: WatchKitSessionClient.live
    )

    static let reducer = Reducer<State, Action, Environment>.combine(
        Reducer { state, action, environment in
            switch action {
            case .connect:
                return environment.watchkitSessionClient.connect(WatchKitId())

            case .watchSessionDidActivate:
                return Effect(value: .requestDataSync)

            case .watchSessionDidDeactivate:
                print("didDisconnect")

            case .requestDataSync:
                let message = ["command": "requestSync"]
                return environment.watchkitSessionClient.sendMessage(WatchKitId(), message)

            case .didReceiveMessage(let message):
                guard let host = message["response"] as? String else { return .none }
                state.shared.host = host

            case .home, . api, .shared:
                return .none
            }
            return .none
        },
        Api.reducer.pullback(
            state: \State.api,
            action: /Action.api,
            environment: { $0 }
        ),
        Home.reducer.pullback(
            state: \State.homeFeature,
            action: /Action.home,
            environment: { $0 }
        ),
        Shared.reducer.pullback(
            state: \State.shared,
            action: /Action.shared,
            environment: { $0 }
        )
    )

    static let store = Store(
        initialState: State(
            home: Home.initialState,
            api: Api.initialState,
            shared: Shared.initialState
        ),
        reducer: reducer,
        environment: initialEnvironment
    )
}

extension Store where State == Main.State, Action == Main.Action {
    var home: Store<Home.HomeFeatureState, Home.Action> {
        scope(state: \.homeFeature, action: Main.Action.home)
    }

    var api: Store<Api.State, Api.Action> {
        scope(state: \.api, action: Main.Action.api)
    }
}
