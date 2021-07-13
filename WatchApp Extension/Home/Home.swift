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
    struct State: Equatable {
        var status: RoborockApi.Status?
        var segments: RoborockApi.Segments?
    }

    enum Action {
        case fetchStatus
        case fetchSegments
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let apiClient: ApiRestClient
    }

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .fetchStatus:
            break
        case .fetchSegments:
            break
        }
        return .none
    }
}
