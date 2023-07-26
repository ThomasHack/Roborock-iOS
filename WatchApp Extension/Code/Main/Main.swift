//
//  Main.swift
//  WatchApp Extension
//
//  Created by Thomas Hack on 17.07.21.
//

import ComposableArchitecture
import Foundation
import RoborockApi
import WatchKit

struct WatchKitId: Hashable {}

struct Main: ReducerProtocol {
    struct State: Equatable {
        var host: String?
        var connectivityState: ConnectivityState = .disconnected
        var segments: Segments?
        var fanspeeds = Fanspeed.allCases
        var showSegmentsModal = false
        var showFanspeedModal = false

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

        var _watchConnectionState: WatchConnection.State?
        var watchConnectionState: WatchConnection.State {
            get {
                if var tempState = _watchConnectionState {
                    tempState.host = host
                    return tempState
                }
                return WatchConnection.State(
                    host: host
                )
            }
            set {
                _watchConnectionState = newValue
            }
        }
    }

    enum Action {
        case toggleSegmentsModal(Bool)
        case toggleFanspeedModal(Bool)
        case fetchSegments
        case startCleaning
        case stopCleaning
        case pauseCleaning
        case driveHome
        case toggleRoom(Int)
        case resetRooms
        case setFanspeed(Fanspeed)
        case api(Api.Action)
        case watchConnection(WatchConnection.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .toggleSegmentsModal(let toggle):
                WKInterfaceDevice.current().play(.click)
                state.showSegmentsModal = toggle
                return .none

            case .toggleFanspeedModal(let toggle):
                WKInterfaceDevice.current().play(.click)
                state.showFanspeedModal = toggle
                return .none

            case .fetchSegments:
                return EffectTask(value: .api(.fetchSegments))

            case .startCleaning:
                state.showFanspeedModal = false
                WKInterfaceDevice.current().play(.success)
                return EffectTask(value: .api(.startCleaningSegment))

            case .stopCleaning:
                WKInterfaceDevice.current().play(.success)
                return EffectTask(value: .api(.stopCleaning))

            case .pauseCleaning:
                WKInterfaceDevice.current().play(.success)
                return EffectTask(value: .api(.pauseCleaning))

            case .driveHome:
                WKInterfaceDevice.current().play(.success)
                return EffectTask(value: .api(.driveHome))

            case .toggleRoom(let roomId):
                return EffectTask(value: .api(.toggleRoom(roomId)))

            case .resetRooms:
                return EffectTask(value: .api(.resetRooms))

            case .setFanspeed(let fanspeed):
                state.showFanspeedModal = false
                WKInterfaceDevice.current().play(.success)
                return EffectTask(value: .api(.setFanspeed(fanspeed)))

            case .api, .watchConnection:
                break
            }
            return .none
        }
        Scope(state: \.apiState, action: /Action.api) {
            Api()
        }
        Scope(state: \.watchConnectionState, action: /Action.watchConnection) {
            WatchConnection()
        }
    }

    static let initialState = State(
        host: UserDefaultsHelper.host
    )

    static let previewState = State(
        host: "roborock.friday.home",
        connectivityState: .connected
    )

    static let previewStore = Store(
        initialState: previewState,
        reducer: Main()
    )

    static let store = Store(
        initialState: initialState,
        reducer: Main()
    )
}

extension Store where State == Main.State, Action == Main.Action {
    var api: Store<Api.State, Api.Action> {
        scope(state: \.apiState, action: Main.Action.api)
    }

    var watchConnection: Store<WatchConnection.State, WatchConnection.Action> {
        scope(state: \.watchConnectionState, action: Main.Action.watchConnection)
    }
}
