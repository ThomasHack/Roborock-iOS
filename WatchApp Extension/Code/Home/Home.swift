//
//  Home.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 13.07.21.
//

import ComposableArchitecture
import Foundation
import RoborockApi
import WatchKit

struct Home: ReducerProtocol {
    struct State: Equatable {
        var showSegmentsModal = false
        var showFanspeedModal = false

        var fanspeeds = Fanspeed.allCases

        var apiState: Api.State
        var sharedState: Shared.State
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
        case none

        case api(Api.Action)
        case shared(Shared.Action)
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

            case .none, .api, .shared:
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
    }

    static let initialState = State(
        showSegmentsModal: false,
        showFanspeedModal: false,
        apiState: Api.initialState,
        sharedState: Shared.initialState

    )

    static let previewState = State(
        showSegmentsModal: false,
        showFanspeedModal: false,
        apiState: Api.previewState,
        sharedState: Shared.previewState
    )

    static let previewStore = Store(
        initialState: Home.previewState,
        reducer: Home()
    )
}
