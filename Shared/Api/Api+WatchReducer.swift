//
//  Api+ReducerWatch.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.02.24.
//

import ComposableArchitecture
import Foundation
import RoborockApi

extension Api {
    var watchReducer: some ReducerOf<Api> {
        Reduce { state, action in
            switch action {
            case .update:
                return .merge(
                    .send(.fetchSegments),
                    .send(.fetchCurrentStatistics)
                )
            case .subscribe:
                return .merge(
                    .send(.fetchState)
                )
            case .unsubscribe:
                Task.cancel(id: EventClient.ID())
            case .toggleRoom(let roomId):
                if let index = state.selectedSegments.firstIndex(of: roomId) {
                    state.selectedSegments.remove(at: index)
                } else {
                    state.selectedSegments.append(roomId)
                }
            case .resetRooms:
                state.selectedSegments = []
            default:
                break
            }
            return .none
        }
    }
}
