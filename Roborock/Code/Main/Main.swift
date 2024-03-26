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
        var host: String?
        var connectivityState: ConnectivityState
        var selectedSegments: [Segment] = []
        var fanSpeedPresets = FanSpeedControlPreset.allCases
        var waterUsagePresets = WaterUsageControlPreset.allCases
        var showSettings = false
        var showRoomSelection = false
        var mapImage: MapImage?
        var entityImages = MapImages(images: [])

        var apiState: Api.State
//            get {
//                if var tempState = _apiState {
//                    tempState.host = host
//                    tempState.segments = selectedSegments
//                    tempState.mapImage = mapImage
//                    tempState.entityImages = entityImages
//                    return tempState
//                }
//            }
//            set {
//                _apiState = newValue
//                connectivityState = newValue.connectivityState
//                selectedSegments = newValue.segments
//                mapImage = newValue.mapImage
//                entityImages = newValue.entityImages
//            }

        var settingsState: Settings.State
//            get {
//                if var tempState = _settingsState {
//                    tempState.host = host
//                    tempState.connectivityState = connectivityState
//                    return tempState
//                }
//            }
//            set {
//                _settingsState = newValue
//                host = newValue.host
//            }

        var watchKitSession: WatchKitSession.State
//            get {
//                if var tempState = _watchKitSession {
//                    tempState.host = host
//                    return tempState
//                }
//            }
//            set {
//                _watchKitSession = newValue
//            }
    }

    @CasePathable
    enum Action: BindableAction {
        case connect
        case disconnect

        case fetchSegments
        case connectButtonTapped
        case toggleSettings(Bool)
        case toggleRoomSelection(Bool)
        case startCleaning
        case stopCleaning
        case pauseCleaning
        case driveHome
        case selectAll

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
                return .none

            case .connectButtonTapped:
                break

            case .toggleSettings(let toggle):
                state.showSettings = toggle

            case .toggleRoomSelection(let toggle):
                state.showRoomSelection = toggle

            case .apiAction(.didConnect):
                state.connectivityState = .connected

            case .apiAction(.didDisconnect):
                state.connectivityState = .disconnected

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
        host: UserDefaultsHelper.host,
        connectivityState: .disconnected,
        apiState: Api.initialState,
        settingsState: Settings.initialState,
        watchKitSession: WatchKitSession.initialState
    )

    static let previewState = State(
        host: "roborock.friday.home",
        connectivityState: .connected,
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
