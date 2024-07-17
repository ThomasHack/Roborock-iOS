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
        @Shared(.appStorage("host")) var host = ""
        @Shared(.inMemory("connectivityState")) var connectivityState: ConnectivityState = .disconnected

        var selectedSegments: [Segment] = []
        var fanSpeedPresets = FanSpeedControlPreset.allCases
        var waterUsagePresets = WaterUsageControlPreset.allCases
        var showSegmentsModal = false
        var showFanspeedModal = false
        var showWaterUsageModal = false

        var apiState: Api.State
        var watchKitSession: WatchKitSession.State
    }

    @CasePathable
    enum Action: BindableAction {
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
        case binding(BindingAction<State>)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
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

            case .api, .watchKitSession, .binding:
                break
            }
            return .none
        }
        Scope(state: \.apiState, action: \.api) {
            Api()
        }
        Scope(state: \.watchKitSession, action: \.watchKitSession) {
            WatchKitSession()
        }
    }

    static let initialState = State(
        apiState: Api.initialState,
        watchKitSession: WatchKitSession.initialState
    )

    static let previewState = State(
        apiState: Api.previewState,
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
    var api: Store<Api.State, Api.Action> {
        scope(state: \.apiState, action: \.api)
    }

    var watchKitSession: Store<WatchKitSession.State, WatchKitSession.Action> {
        scope(state: \.watchKitSession, action: \.watchKitSession)
    }
}
