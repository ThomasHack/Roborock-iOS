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

@Reducer
struct Main {
    @ObservableState
    struct State: Equatable {
        var host: String? {
            didSet {
                UserDefaultsHelper.setHost(host)
            }
        }
        var connectivityState: ConnectivityState = .disconnected
        var selectedSegments: [Segment] = []
        var fanSpeedPresets = FanSpeedControlPreset.allCases
        var waterUsagePresets = WaterUsageControlPreset.allCases
        var showSegmentsModal = false
        var showFanspeedModal = false
        var showWaterUsageModal = false

        var _apiState: Api.State?
        var apiState: Api.State {
            get {
                if var tempState = _apiState {
                    tempState.host = host
                    tempState.connectivityState = connectivityState
                    tempState.segments = selectedSegments
                    return tempState
                }
                return Api.State(
                    host: host,
                    connectivityState: connectivityState,
                    segments: selectedSegments
                )
            }
            set {
                _apiState = newValue
                selectedSegments = newValue.segments
                connectivityState = newValue.connectivityState
            }
        }

        var _watchKitSessionState: WatchKitSession.State?
        var watchKitSessionState: WatchKitSession.State {
            get {
                if var tempState = _watchKitSessionState {
                    tempState.host = host
                    return tempState
                }
                return WatchKitSession.State(
                    host: host
                )
            }
            set {
                _watchKitSessionState = newValue
                host = newValue.host
            }
        }
    }

    @CasePathable
    enum Action {
        case toggleSegmentsModal(Bool)
        case toggleFanspeedModal(Bool)
        case toggleWaterUsageModal(Bool)
        case fetchSegments
        case startCleaning
        case stopCleaning
        case pauseCleaning
        case driveHome
        case toggleRoom(Segment)
        case resetRooms
        case controlFanSpeed(FanSpeedControlPreset)
        case controlWaterUsage(WaterUsageControlPreset)
        case api(Api.Action)
        case watchKitSession(WatchKitSession.Action)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .toggleSegmentsModal(let toggle):
                state.showSegmentsModal = toggle
                WKInterfaceDevice.current().play(.click)

            case .toggleFanspeedModal(let toggle):
                state.showFanspeedModal = toggle
                WKInterfaceDevice.current().play(.click)

            case .toggleWaterUsageModal(let toggle):
                state.showWaterUsageModal = toggle
                WKInterfaceDevice.current().play(.click)

            case .fetchSegments:
                return .send(.api(.fetchSegments))

            case .startCleaning:
                state.showSegmentsModal = false
                WKInterfaceDevice.current().play(.success)
                return .send(.api(.startCleaningSegment))

            case .stopCleaning:
                WKInterfaceDevice.current().play(.success)
                return .send(.api(.stopCleaning))

            case .pauseCleaning:
                WKInterfaceDevice.current().play(.success)
                return .send(.api(.pauseCleaning))

            case .driveHome:
                WKInterfaceDevice.current().play(.success)
                return .send(.api(.driveHome))

            case .toggleRoom(let roomId):
                return .send(.api(.toggleRoom(roomId)))

            case .resetRooms:
                return .send(.api(.resetRooms))

            case .controlFanSpeed(let fanspeed):
                state.showFanspeedModal = false
                WKInterfaceDevice.current().play(.success)
                return .send(.api(.controlFanSpeed(fanspeed)))

            case .controlWaterUsage(let waterUsage):
                state.showWaterUsageModal = false
                WKInterfaceDevice.current().play(.success)
                return .send(.api(.controlWaterUsage(waterUsage)))

            case .api, .watchKitSession:
                break
            }
            return .none
        }
        Scope(state: \.apiState, action: \.api) {
            Api()
        }
        Scope(state: \.watchKitSessionState, action: /Action.watchKitSession) {
            WatchKitSession()
        }
    }

    static let initialState = State(
        host: UserDefaultsHelper.host
    )

    static let previewState = State(
        host: "roborock.friday.home",
        connectivityState: .connected
    )

    static let previewStore = Store(initialState: previewState) {
        Main()
    }

    static let store = Store(initialState: initialState) {
        Main()
    }
}

extension Store where State == Main.State, Action == Main.Action {
    var api: Store<Api.State, Api.Action> {
        scope(state: \.apiState, action: \.api)
    }

    var watchKitSession: Store<WatchKitSession.State, WatchKitSession.Action> {
        scope(state: \.watchKitSessionState, action: \.watchKitSession)
    }
}
