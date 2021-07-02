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
        case didConnect
        case connect(URL)
        case didDisconnect
        case disconnect
        
        case fetchConsumableStatus
        case fetchWifiStatus
        case fetchSpots
        case fetchZones
        
        case fetchSegments
        case segmentsResponse(Result<Segment, ApiRestClient.Failure>)
        
        case startCleaningSegment([Int])
        case startCleaningSegmentResponse(Result<Data, ApiRestClient.Failure>)
        case stopCleaning
        case stopCleaningResponse(Result<Data, ApiRestClient.Failure>)
        case pauseCleaning
        case pauseCleaningResponse(Result<Data, ApiRestClient.Failure>)
        
        case driveHome
        case driveHomeResponse(Result<Data, ApiRestClient.Failure>)
        
        case didUpdateStatus(Status)
        case didReceiveWebSocketEvent(ApiWebSocketEvent)

        case setMapData(Result<MapData, MapDataParser.MapDataError>)
        case setMapImage(UIImage)

        case setFanspeed(Int)
        case setFanspeedResponse(Result<Data, ApiRestClient.Failure>)
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
                return environment.mapDataParser.parse(data)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(Action.setMapData)
            default:
                return .none
            }
        case .setMapData(let result):
            switch result {
            case .success(let mapData):
                state.mapData = mapData
                if let image = mapData.image {
                    return Effect(value: .setMapImage(image))
                }
            case .failure(let error):
                print("\(error.localizedDescription)")
            }
            return .none

        case .setMapImage(let image):
            state.mapImage = image
            return .none

        case .setFanspeed(let fanspeed):
            return environment.apiClient.setFanspeed(ApiId(), fanspeed)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.setFanspeedResponse)

        case .setFanspeedResponse:
            return .none
            
        default:
            return .none
        }
    }
    
    static let initialState = State()
    
    static let previewState = State()
//        status: Status(state: 2, otaState: "idle", messageVersion: 3, battery: 94, cleanTime: 4, cleanArea: 0, errorCode: 0, mapPresent: 1, inCleaning: 0, inReturning: 0, inFreshState: 1, waterBoxStatus: 0, fanPower: 101, dndEnabled: 0, mapStatus: 3, mainBrushLife: 84, sideBrushLife: 75, filterLife: 67, stateHumanReadable: "Charger disconnected", model: "roborock.vacuum.s5", errorHumanReadable: "No error"),
//        segments: Segment(segment: [
//            SegmentValue(id: 16, name: "Arbeitszimmer"),
//            SegmentValue(id: 17, name: "Wohnzimmer"),
//            SegmentValue(id: 18, name: "Vorrat"),
//            SegmentValue(id: 19, name: "Badezimmer"),
//            SegmentValue(id: 20, name: "Gästebad"),
//            SegmentValue(id: 21, name: "Schlafzimmer"),
//            SegmentValue(id: 22, name: "Flur"),
//            SegmentValue(id: 23, name: "Küche")
//        ]
//        )
//    )
}
