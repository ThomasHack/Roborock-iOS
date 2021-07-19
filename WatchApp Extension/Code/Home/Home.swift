//
//  Home.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 13.07.21.
//

import ComposableArchitecture
import Foundation
import RoborockApi

enum Home {
    struct State: Equatable {}

    enum Action {
        case fetchSegments
        case startCleaning
        case stopCleaning
        case pauseCleaning
        case driveHome
        case toggleRoom(Int)
        case resetRooms
        case none

        case api(Api.Action)
        case shared(Shared.Action)
    }

    typealias Environment = Main.Environment

    static let reducer = Reducer<HomeFeatureState, Action, Environment>.combine(
        Reducer { _, action, _ in
            switch action {
            case .fetchSegments:
                return Effect(value: .api(.fetchSegments))

            case .startCleaning:
                return Effect(value: .api(.startCleaningSegment))

            case .stopCleaning:
                return Effect(value: .api(.stopCleaning))

            case .pauseCleaning:
                return Effect(value: .api(.pauseCleaning))

            case .driveHome:
                return Effect(value: .api(.driveHome))

            case .toggleRoom(let roomId):
                return Effect(value: .api(.toggleRoom(roomId)))

            case .resetRooms:
                return Effect(value: .api(.resetRooms))

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

    static let initialState = State()

    static let initialEnvironment = Environment(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        restClient: RestClient(baseUrl: "http://roborock/api/"),
        websocketClient: ApiWebSocketClient.live
    )
}
