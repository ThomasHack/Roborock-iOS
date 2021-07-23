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

enum Home {
    struct State: Equatable {
        var showSegmentsModal: Bool
        var showFanspeedModal: Bool

        var fanspeeds = Fanspeed.allCases
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

    typealias Environment = Main.Environment

    static let reducer = Reducer<HomeFeatureState, Action, Environment>.combine(
        Reducer { state, action, _ in
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
                return Effect(value: .api(.fetchSegments))

            case .startCleaning:
                state.showFanspeedModal = false
                WKInterfaceDevice.current().play(.success)
                return Effect(value: .api(.startCleaningSegment))

            case .stopCleaning:
                WKInterfaceDevice.current().play(.success)
                return Effect(value: .api(.stopCleaning))

            case .pauseCleaning:
                WKInterfaceDevice.current().play(.success)
                return Effect(value: .api(.pauseCleaning))

            case .driveHome:
                WKInterfaceDevice.current().play(.success)
                return Effect(value: .api(.driveHome))

            case .toggleRoom(let roomId):
                return Effect(value: .api(.toggleRoom(roomId)))

            case .resetRooms:
                return Effect(value: .api(.resetRooms))

            case .setFanspeed(let fanspeed):
                state.showFanspeedModal = false
                WKInterfaceDevice.current().play(.success)
                return Effect(value: .api(.setFanspeed(fanspeed)))

            case .none, .api, .shared:
                break
            }
            return .none
        },
        Shared.reducer.pullback(
            state: \HomeFeatureState.shared,
            action: /Action.shared,
            environment: { $0 }
        ),
        Api.reducer.pullback(
            state: \HomeFeatureState.api,
            action: /Action.api,
            environment: { $0 }
        )
    )

    static let initialState = State(
        showSegmentsModal: false,
        showFanspeedModal: false
    )

    static let previewStore = Store(
        initialState: Home.previewState,
        reducer: Home.reducer,
        environment: Main.initialEnvironment
    )
}
