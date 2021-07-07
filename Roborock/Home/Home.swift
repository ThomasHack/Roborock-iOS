//
//  Home.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import Foundation
import ComposableArchitecture
import SwiftUI

enum Home {
    struct State: Equatable {
        var presentRoomSelection: Bool = false
    }
    
    enum Action {
        case connect
        case connectButtonTapped
        case fetchSegments
        case startCleaning
        case stopCleaning
        case pauseCleaning
        case driveHome
        case selectAll
        case settingsButtonTapped
        case toggleRoomSelection(Bool)
        case toggleSettingsModal(Bool)
        
        case api(Api.Action)
        case shared(Shared.Action)
        case none
    }
    
    typealias Environment = Main.Environment
    
    static let reducer = Reducer<HomeFeatureState, Action, Environment>.combine(
        Reducer { state, action, environment in
            switch action {
            case .connect:
                let url = URL(string: "http://roborock/")
                return Effect(value: Action.api(.connect(url!)))
                
            case .connectButtonTapped:
                switch state.connectivityState {
                case .connected, .connecting:
                    state.showSettingsModal = false
                    return Effect(value: Action.api(.disconnect))

                case .disconnected:
                    guard let url = URL(string: state.hostInput) else { return .none }
                    state.showSettingsModal = false
                    return Effect(value: Action.api(.connect(url)))
                }

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

            case .settingsButtonTapped:
                return Effect(value: Action.shared(.showSettingsModal))

            case .toggleRoomSelection(let toggle):
                state.presentRoomSelection = toggle

            case .toggleSettingsModal(let toggle):
                return Effect(value: Action.shared(.toggleSettingsModal(toggle)))

            case .api, .shared, .none:
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
}
