//
//  Api.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import UIKit
import ComposableArchitecture

struct ApiId: Hashable {}

enum ConnectivityState {
    case connected
    case connecting
    case disconnected
}

enum Api {
    struct State: Equatable {
        var connectivityState: ConnectivityState = .disconnected
        
        var status: Status?
        var segments: Segment?
        var mapData: MapData?
        var mapImage: UIImage?
    }
    
    enum Action: Equatable {
        case connect(URL)
        case disconnect
        case fetchCurrentStatus
        case statusResponse(Result<Status, ApiRestClient.Failure>)
        case fetchConsumableStatus
        case fetchWifiStatus
        case fetchSpots
        case fetchZones
        case fetchSegments
        case segmentsResponse(Result<Segment, ApiRestClient.Failure>)
        case fetchSimpleMap
        case mapResponse(Result<Data, ApiRestClient.Failure>)
        case fetchMapData
        case startCleaningSegment([Int])
        case startCleaningSegmentResponse(Result<Data, ApiRestClient.Failure>)
        case stopCleaning
        case stopCleaningResponse(Result<Data, ApiRestClient.Failure>)
        case pauseCleaning
        case pauseCleaningResponse(Result<Data, ApiRestClient.Failure>)
        case refreshState(Result<Data, ApiRestClient.Failure>)
        case refreshStateAndMap(Result<Data, ApiRestClient.Failure>)
        case driveHome
        case driveHomeResponse(Result<Data, ApiRestClient.Failure>)
        
        case didConnect
        case didDisconnect
        case didUpdateStatus(Status)
        case didReceiveWebSocketEvent(ApiWebSocketEvent)
    }
    
    typealias Environment = Main.Environment
    
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .connect(let url):
            return environment.websocketClient.connect(ApiId(), url)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
            
        case .disconnect:
            return environment.websocketClient.disconnect(ApiId())
                .receive(on: environment.mainQueue)
                .eraseToEffect()
            
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
                .map(Action.startCleaningSegmentResponse)
            
        case .stopCleaning:
            return environment.apiClient.stopCleaning(ApiId())
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.stopCleaningResponse)
            
        case .pauseCleaning:
            return environment.apiClient.pauseCleaning(ApiId())
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.pauseCleaningResponse)
            
        case .driveHome:
            return environment.apiClient.driveHome(ApiId())
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.driveHomeResponse)
            
        case .refreshStateAndMap(let response):
            switch response {
            case .success(_):
                return .merge(
                    Effect(value: Action.fetchCurrentStatus),
                    Effect(value: Action.fetchSimpleMap)
                )
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
            return .none
            
        case .refreshState(let response):
            switch response {
            case .success(_):
                return Effect(value: Action.fetchCurrentStatus)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
            return .none
            
        case .didConnect:
            state.connectivityState = .connected
            return .none
            
        case .didDisconnect:
            state.connectivityState = .disconnected
            return .none
            
        case .didUpdateStatus(let status):
            state.status = status
            return .none
            
        case .didReceiveWebSocketEvent(let event):
            switch event {
            case .binary(let data):
                let parser = MapDataParser()
                state.mapData = parser.parse(data)
                if let mapImage = state.mapData?.image {
                    state.mapImage = mapImage
                }
                return .none
            default:
                return .none
            }
            
        default:
            return .none
        }
    }
    
    static let initialState = State()
    
    static let previewState = State(
        status: Status(state: 2, otaState: "idle", messageVersion: 3, battery: 94, cleanTime: 4, cleanArea: 0, errorCode: 0, mapPresent: 1, inCleaning: 0, inReturning: 0, inFreshState: 1, waterBoxStatus: 0, fanPower: 101, dndEnabled: 0, mapStatus: 3, mainBrushLife: 84, sideBrushLife: 75, filterLife: 67, stateHumanReadable: "Charger disconnected", model: "roborock.vacuum.s5", errorHumanReadable: "No error"),
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
