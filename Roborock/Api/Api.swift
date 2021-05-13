//
//  Api.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import UIKit
import ComposableArchitecture

struct ApiId: Hashable {}

enum Api {
    struct State: Equatable {
        var status: Status?
        var segments: Segment?
        var mapImage: UIImage?
    }
    
    enum Action: Equatable {
        case fetchCurrentStatus
        case statusResponse(Result<Status, ApiClient.Failure>)
        case fetchConsumableStatus
        case fetchWifiStatus
        case fetchSpots
        case fetchZones
        case fetchSegments
        case segmentsResponse(Result<Segment, ApiClient.Failure>)
        case fetchSimpleMap
        case mapResponse(Result<Data, ApiClient.Failure>)
        case fetchMapData
        case startCleaningSegment([Int])
        case startCleaningSegmentResponse(Result<Data, ApiClient.Failure>)
        case stopCleaning
        case stopCleaningResponse(Result<Data, ApiClient.Failure>)
        case pauseCleaning
        case pauseCleaningResponse(Result<Data, ApiClient.Failure>)
        case refreshState(Result<Data, ApiClient.Failure>)
        case refreshStateAndMap(Result<Data, ApiClient.Failure>)
        case driveHome
    }
    
    typealias Environment = Main.Environment
    
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .fetchCurrentStatus:
            return environment.apiClient.fetchCurrentStatus(ApiId())
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.statusResponse)
        case .statusResponse(let response):
            switch response {
            case .success(let status):
                state.status = status
                return .none
            case .failure(let error):
                print("error: \(error)")
                return .none
            }
        case .fetchSegments:
            return environment.apiClient.fetchSegments(ApiId())
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.segmentsResponse)
        case .segmentsResponse(let response):
            switch response {
            case .success(let segments):
                state.segments = segments
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
            return .none
        case .fetchSimpleMap:
            return environment.apiClient.fetchMap(ApiId())
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.mapResponse)
        case .mapResponse(let response):
            switch response {
            case .success(let data):
                if let image = UIImage(data: data) {
                    state.mapImage = image
                }
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
            return .none
        case .startCleaningSegment(let rooms):
            return environment.apiClient.startCleaningSegment(ApiId(), rooms)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.refreshState)
        case .stopCleaning:
            return environment.apiClient.stopCleaning(ApiId())
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.refreshState)
        case .pauseCleaning:
            return environment.apiClient.pauseCleaning(ApiId())
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.refreshState)
        case .driveHome:
            return environment.apiClient.driveHome(ApiId())
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.refreshState)
        case .refreshStateAndMap(let response):
            switch response {
            case .success(_):
                return .merge(
                    Effect(value: Action.fetchCurrentStatus),
                    Effect(value: Action.fetchSimpleMap)
                )
                .debounce(id: ApiId(), for: 3.0, scheduler: environment.mainQueue)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
            return .none
        case .refreshState(let response):
            switch response {
            case .success(_):
                return Effect(value: Action.fetchCurrentStatus)
                    .debounce(id: ApiId(), for: 3.0, scheduler: environment.mainQueue)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
            return .none
        default:
            return .none
        }
    }
    
    static let initialState = State()
    
    static let previewState = State(
        status: Status(battery: 100, cleanTime: 30, cleanArea: 40, inCleaning: 0, inReturning: 0, humanState: "In Progress"),
        segments: Segment(segment: [
            SegmentValue(id: 16, name: "Arbeitszimmer"),
            SegmentValue(id: 17, name: "Wohnzimmer"),
            SegmentValue(id: 18, name: "Vorrat"),
            SegmentValue(id: 19, name: "Badezimmer"),
            SegmentValue(id: 20, name: "Gästebad"),
            SegmentValue(id: 21, name: "Schlafzimmer"),
            SegmentValue(id: 22, name: "Flur"),
            SegmentValue(id: 23, name: "Küche")
        ]
        )
    )
}
