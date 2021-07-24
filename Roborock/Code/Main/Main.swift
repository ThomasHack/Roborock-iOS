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

enum Main {

    struct State: Equatable {
        var home: Home.State
        var api: Api.State
        var shared: Shared.State
        var settings: Settings.State
        var watchConnection: WatchConnection.State

        var homeFeature: Home.HomeFeatureState {
            get { Home.HomeFeatureState(home: self.home, settings: self.settings, shared: self.shared, api: self.api) }
            set { self.home = newValue.home; self.settings = newValue.settings; self.shared = newValue.shared; self.api = newValue.api }
        }

        var settingsFeature: Settings.SettingsFeatureState {
            get { Settings.SettingsFeatureState(settings: self.settings, shared: self.shared, api: self.api) }
            set { self.settings = newValue.settings; self.shared = newValue.shared }
        }

        var watchConnectionFeature: WatchConnection.WatchConnectionFeatureState {
            get { WatchConnection.WatchConnectionFeatureState(watchConnection: self.watchConnection, shared: self.shared) }
            set { self.watchConnection = newValue.watchConnection; self.shared = newValue.shared }
        }
    }

    enum Action {
        case home(Home.Action)
        case api(Api.Action)
        case shared(Shared.Action)
        case settings(Settings.Action)
        case watchConnection(WatchConnection.Action)
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let restClient: RestClient
        let websocketClient: ApiWebSocketClient
        let watchkitSessionClient: WatchKitSessionClient
        let rrFileParser: RRFileParser
    }

    static let initialEnvironment = Environment(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        restClient: RestClient.live,
        websocketClient: ApiWebSocketClient.live,
        watchkitSessionClient: WatchKitSessionClient.live,
        rrFileParser: RRFileParser()
    )

    static let reducer = Reducer<State, Action, Environment>.combine(
        Reducer { _, action, _ in
            switch action {
            case .home, . api, .shared, .settings, .watchConnection:
                break
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
        ),
        Settings.reducer.pullback(
            state: \State.settingsFeature,
            action: /Action.settings,
            environment: { $0 }
        ),
        WatchConnection.reducer.pullback(
            state: \State.watchConnectionFeature,
            action: /Action.watchConnection,
            environment: { $0 }
        )
    )

    static let store = Store<Main.State, Main.Action>(
        initialState: State(
            home: Home.initialState,
            api: Api.initialState,
            shared: Shared.initialState,
            settings: Settings.initialState,
            watchConnection: WatchConnection.initialState
        ),
        reducer: reducer,
        environment: initialEnvironment
    )

    static let previewStoreHome = Store(
        initialState: Home.previewState,
        reducer: Home.reducer,
        environment: initialEnvironment
    )

    static let previewStoreSettings = Store<Settings.SettingsFeatureState, Settings.Action>(
        initialState: Settings.previewState,
        reducer: Settings.reducer,
        environment: initialEnvironment
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

    var shared: Store<Shared.State, Shared.Action> {
        scope(state: \.shared, action: Main.Action.shared)
    }

    var watchConnection: Store<WatchConnection.WatchConnectionFeatureState, WatchConnection.Action> {
        scope(state: \.watchConnectionFeature, action: Main.Action.watchConnection)
    }
}
