//
//  Home.swift
//  WatchApp Extension
//
//  Created by Hack, Thomas on 13.07.21.
//

import ComposableArchitecture
import Foundation
import Roborock_Api

enum Home {
    struct State: Equatable {
        var status: Roborock_Api.RestStatus?
        var segments: [Roborock_Api.Segment] = []

        var humanState: String {
            guard let humanState = status?.humanState else {
                return "-"
            }
            return humanState
        }

        var battery: String {
            guard let status = status else {
                return "-"
            }
            return "\(status.battery)"
        }

        var cleanTime: String {
            guard let status = status else {
                return "-"
            }
            let minutes = String(format: "%02d", (status.cleanTime % 3600) / 60)
            let seconds = String(format: "%02d", (status.cleanTime % 3600) % 60)
            return "\(minutes):\(seconds)"
        }

        var cleanArea: String {
            guard let status = status else {
                return "-"
            }
            return String(format: "%.2f", Double(status.cleanArea) / 1000000)
        }
    }

    enum Action {
        case fetchStatus
        case fetchStatusResponse(Result<RestStatus, RestClientError>)
        case fetchSegments
        case fetchSegmentsResponse(Result<Segments, RestClientError>)
        case none
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let restClient: RestClient
    }

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .fetchStatus:
            return environment.restClient.fetchStatus()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.fetchStatusResponse)
        case .fetchStatusResponse(let result):
            switch result {
            case .success(let status):
                state.status = status
                print("status: \(status)")
            case .failure(let error):
                print("\(error.localizedDescription)")
            }
        case .fetchSegments:
            return environment.restClient.fetchSegments()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.fetchSegmentsResponse)
        case .fetchSegmentsResponse(let result):
            switch result {
            case .success(let segments):
                state.segments = segments.data
                print("segments: \(segments)")
            case .failure(let error):
                print("\(error.localizedDescription)")
            }
        case .none:
            break
        }
        return .none
    }

    static let initialEnvironment = Environment(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        restClient: RestClient(baseUrl: "http://roborock/api/")
    )

    static let store = Store(
        initialState: State(),
        reducer: reducer,
        environment: initialEnvironment
    )

    static let previewStore = Store(
        initialState: State(
            status: RestStatus(messageVersion: 3,
                               state: 8,
                               battery: 100,
                               cleanTime: 3,
                               cleanArea: 0,
                               errorCode: 0,
                               mapPresent: 1,
                               inCleaning: 0,
                               inReturning: 0,
                               inFreshState: 1,
                               labStatus: 1,
                               waterBoxStatus: 0,
                               fanPower: 104,
                               dndEnabled: 0,
                               mapStatus: 3,
                               lockStatus: 0,
                               humanState: "Charging",
                               humanError: "No error",
                               model: "roborock.vaccum.s5"
                              ),
            segments: [
                Segment(id: 1, name: "Arbeitszimmer"),
                Segment(id: 2, name: "Wohnzimmer"),
                Segment(id: 3, name: "Schlafzimmer"),
                Segment(id: 4, name: "Badezimmer"),
                Segment(id: 5, name: "Küche")
            ]
        ),
        reducer: reducer,
        environment: initialEnvironment
    )
}
