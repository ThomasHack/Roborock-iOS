//
//  Home.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import Foundation
import ComposableArchitecture

enum Home {
    struct State: Equatable {
        var presentRoomSelection: Bool = false
    }
    
    enum Action {
        case connect
        case fetchSegments
        case startCleaning
        case stopCleaning
        case pauseCleaning
        case driveHome
        case selectAll
        case toggleRoomSelection(Bool)
        
        case api(Api.Action)
        case none
    }
    
    typealias Environment = Main.Environment
    
    static let reducer = Reducer<HomeFeatureState, Action, Environment>.combine(
        Reducer { state, action, environment in
            switch action {
            case .connect:
                let url = URL(string: "http://roborock/")
                return Effect(value: Action.api(.connect(url!)))

            case .fetchSegments:
                return Effect(value: Action.api(.fetchSegments))

            case .startCleaning:
                return Effect(value: Action.api(.startCleaningSegment))

            case .stopCleaning:
                return Effect(value: Action.api(.stopCleaning))

            case .pauseCleaning:
                return Effect(value: Action.api(.pauseCleaning))

            case .driveHome:
                return Effect(value: Action.api(.driveHome))

            case .selectAll:
                if state.rooms.isEmpty {
                    guard let segments = state.api.segments else { return .none }
                    let rooms = segments.data.map { $0.id!}
                    state.rooms = rooms
                    return .none
                }
                state.rooms = []
                return .none

            case .toggleRoomSelection(let toggle):
                state.presentRoomSelection = toggle
                return .none

            case .api, .none:
                return .none
            }
        },
        Api.reducer.pullback(
            state: \HomeFeatureState.api,
            action: /Action.api,
            environment: { $0 }
        )
    )
    
    static let initialState = State()
}
