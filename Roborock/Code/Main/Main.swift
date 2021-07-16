//
//  Main.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import Foundation
import Roborock_Api

enum Main {

    struct State: Equatable {
        var home: Home.State
        var api: Api.State
        var shared: Shared.State
        var settings: Settings.State

        var homeFeature: Home.HomeFeatureState {
            get { Home.HomeFeatureState(home: self.home, settings: self.settings, shared: self.shared, api: self.api) }
            set { self.home = newValue.home; self.shared = newValue.shared; self.api = newValue.api }
        }

        var settingsFeature: Settings.SettingsFeatureState {
            get { Settings.SettingsFeatureState(settings: self.settings, shared: self.shared, api: self.api) }
            set { self.settings = newValue.settings; self.shared = newValue.shared }
        }
    }

    enum Action {
        case home(Home.Action)
        case api(Api.Action)
        case shared(Shared.Action)
        case settings(Settings.Action)
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let restClient: RestClient
        let websocketClient: ApiWebSocketClient
        let rrFileParser: RRFileParser
    }

    static let reducer = Reducer<State, Action, Environment>.combine(
        Reducer { _, action, _ in
            switch action {
            case .home, . api, .shared, .settings:
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
        ),
        Shared.reducer.pullback(
            state: \State.shared,
            action: /Action.shared,
            environment: { $0 }
        ),
        Settings.reducer.pullback(
            state: \State.settingsFeature,
            action: /Action.settings,
            environment: { $0 }
        )
    )

    static let store = Store(
        initialState: State(
            home: Home.initialState,
            api: Api.initialState,
            shared: Shared.initialState,
            settings: Settings.initialState
        ),
        reducer: reducer,
        environment: initialEnvironment
    )

    static let previewStoreHome = Store(
        initialState: Home.previewState,
        reducer: Home.reducer,
        environment: Main.Environment(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            restClient: RestClient(baseUrl: "http://roborock/api/"),
            websocketClient: ApiWebSocketClient.live,
            rrFileParser: RRFileParser()
        )
    )

    static let previewStoreSettings = Store(
        initialState: Settings.previewState,
        reducer: Settings.reducer,
        environment: Main.Environment(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            restClient: RestClient(baseUrl: "http://roborock/api/"),
            websocketClient: ApiWebSocketClient.live,
            rrFileParser: RRFileParser()
        )
    )

    static let initialEnvironment = Environment(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        restClient: RestClient(baseUrl: "http://roborock/api/"),
        websocketClient: ApiWebSocketClient.live,
        rrFileParser: RRFileParser()
    )
}

extension Store where State == Main.State, Action == Main.Action {
    var home: Store<Home.HomeFeatureState, Home.Action> {
        scope(state: \.homeFeature, action: Main.Action.home)
    }

    var settings: Store<Settings.SettingsFeatureState, Settings.Action> {
        scope(state: \.settingsFeature, action: Main.Action.settings)
    }

    var api: Store<Api.State, Api.Action> {
        scope(state: \.api, action: Main.Action.api)
    }
}
