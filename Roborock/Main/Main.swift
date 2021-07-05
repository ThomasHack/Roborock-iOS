//
//  Main.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import Foundation
import ComposableArchitecture

enum Main {
    
    struct State: Equatable {
        var home: Home.State
        var api: Api.State
        
        var homeFeature: Home.HomeFeatureState {
            get { Home.HomeFeatureState(home: self.home, api: self.api) }
            set { self.home = newValue.home; self.api = newValue.api }
        }
    }
    
    enum Action {
        case home(Home.Action)
        case api(Api.Action)
    }
    
    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let apiClient: ApiRestClient
        let websocketClient: ApiWebSocketClient
        let rrFileParser: RRFileParser
        let defaults: UserDefaults
    }
    
    static let reducer = Reducer<State, Action, Environment>.combine(
        Reducer { state, action, environment in
            switch action {
            case .home:
                return .none
            case .api:
                return .none
            }
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
        )
    )
    
    static let store = Store(
        initialState: State(
            home: Home.initialState,
            api: Api.initialState
        ),
        reducer: reducer,
        environment: initialEnvironment
    )
    
    static let previewStoreHome = Store(
        initialState: Home.previewState,
        reducer: Home.reducer,
        environment: Main.Environment(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            apiClient: ApiRestClient.live,
            websocketClient: ApiWebSocketClient.live,
            rrFileParser: RRFileParser(),
            defaults: UserDefaults.standard
        )
    )
    
    static let initialEnvironment = Environment(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        apiClient: ApiRestClient.live,
        websocketClient: ApiWebSocketClient.live,
        rrFileParser: RRFileParser(),
        defaults: UserDefaults.standard
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
