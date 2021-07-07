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

        var segments: Segment?
        var mapData: MapData?

        var mapImage: UIImage?
        var pathImage: UIImage?
        var forbiddenZonesImage: UIImage?
        var robotImage: UIImage?
        var chargerImage: UIImage?
        var segmentLabelsImage: UIImage?

        var initialUpdateDone: Bool {
            return mapImage != nil
            && pathImage != nil
            && forbiddenZonesImage != nil
            && robotImage != nil
            && chargerImage != nil
            && segmentLabelsImage != nil
        }

        var status: Status? {
            willSet {
                if self.inCleaning && newValue?.inCleaning == 0 {
                    ViewStore(Main.store.api).send(.resetRooms)
                }
            }
        }

        var state: VacuumState {
            guard let state = status?.vacuumState else {
                return VacuumState.unknown
            }
            return state
        }

        var isConnected: Bool {
            return connectivityState == .connected
        }
        
        var inCleaning: Bool {
            guard let status = status else {
                return false
            }
            return status.inCleaning != 0
        }
        
        var inReturning: Bool {
            guard let status = status else {
                return false
            }
            return status.inReturning != 0
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
            let minutes = String(format: "%02d", (status.cleanTime % 3600)/60)
            let seconds = String(format: "%02d", (status.cleanTime % 3600) % 60)
            return "\(minutes):\(seconds)"
        }
        
        var cleanArea: String {
            guard let status = status else {
                return "-"
            }
            return String(format: "%.2f", Double(status.cleanArea)/1000000)
        }
        
        var rooms: [Int] = []
    }
    
    enum Action: Equatable {
        case connect(URL)
        case didConnect
        case disconnect
        case didDisconnect
        case resetState
        case didReceiveWebSocketEvent(ApiWebSocketEvent)
        case didUpdateStatus(Status)

        case fetchSegments

        case fetchSegmentsResponse(Result<Segment, ApiRestClient.Failure>)
        
        case startCleaningSegment
        case startCleaningSegmentResponse(Result<Data, ApiRestClient.Failure>)
        case stopCleaning
        case stopCleaningResponse(Result<Data, ApiRestClient.Failure>)
        case pauseCleaning
        case pauseCleaningResponse(Result<Data, ApiRestClient.Failure>)
        
        case driveHome
        case driveHomeResponse(Result<Data, ApiRestClient.Failure>)

        case refreshMapImage

        case setFanspeed(Int)
        case setFanspeedResponse(Result<Data, ApiRestClient.Failure>)
        
        case toggleRoom(Int)
        case resetRooms

        case generateMapImage
        case generatePathImage
        case generateForbiddenZones
        case generateRobotImage
        case generateChargerImage
        case generateSegmentLabelsImage

        case setMapData(Result<MapData, ParsingError>)
        case setMapImage(Result<UIImage, ImageGenerationError>)
        case setPathImage(Result<UIImage, ImageGenerationError>)
        case setForbiddenZonesImage(Result<UIImage, ImageGenerationError>)
        case setRobotImage(Result<UIImage, ImageGenerationError>)
        case setChargerImage(Result<UIImage, ImageGenerationError>)
        case setSegmentLabelsImage(Result<UIImage, ImageGenerationError>)
    }
    
    typealias Environment = Main.Environment
    
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .connect(let url):
            return environment.websocketClient.connect(ApiId(), url)
                .receive(on: environment.mainQueue)
                .eraseToEffect()

        case .didConnect:
            state.connectivityState = .connected
            return .merge(
                Effect(value: .fetchSegments)
            )

        case .disconnect:
            return environment.websocketClient.disconnect(ApiId())
                .receive(on: environment.mainQueue)
                .eraseToEffect()

        case .didDisconnect:
            state.connectivityState = .disconnected
            return Effect(value: .resetState)
            
        case .resetState:
            state.status = nil
            state.rooms = []
            state.mapImage = nil
            state.pathImage = nil
            state.forbiddenZonesImage = nil
            state.robotImage = nil
            state.chargerImage = nil
            state.segmentLabelsImage = nil

        case .didReceiveWebSocketEvent(let event):
            switch event {
            case .binary(let data):
                return environment.rrFileParser.parse(data)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(Action.setMapData)
            default:
                break
            }

        case .didUpdateStatus(let status):
            state.status = status
            
        case .fetchSegments:
            return environment.apiClient.fetchSegments(ApiId())
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.fetchSegmentsResponse)
            
        case .fetchSegmentsResponse(let response):
            switch response {
            case .success(let segments):
                state.segments = segments
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
            return .none
            
        case .startCleaningSegment:
            return environment.apiClient.startCleaningSegment(ApiId(), state.rooms)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.startCleaningSegmentResponse)
            
        case .startCleaningSegmentResponse(let result):
            switch result {
            case .success:
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
            return .none
            
        case .stopCleaning:
            return environment.apiClient.stopCleaning(ApiId())
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.stopCleaningResponse)
            
        case .stopCleaningResponse(let result):
            switch result {
            case .success:
                return Effect(value: .resetRooms)
            case .failure(let error):
                print(error.localizedDescription)
            }
            return .none
            
        case .pauseCleaning:
            return environment.apiClient.pauseCleaning(ApiId())
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.pauseCleaningResponse)

        case .pauseCleaningResponse(let result):
            switch result {
            case .success:
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
            return .none

        case .driveHome:
            return environment.apiClient.driveHome(ApiId())
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.driveHomeResponse)

        case .driveHomeResponse(let result):
            switch result {
            case .success:
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
            return .none

        case .setMapData(let result):
            switch result {
            case .success(let mapData):
                state.mapData = mapData
                if state.initialUpdateDone {
                    // Static images have been generated already
                    // So just update the changed ones
                    return .merge(
                        Effect(value: Action.generateMapImage),
                        Effect(value: Action.generatePathImage),
                        Effect(value: Action.generateRobotImage)
                    )
                } else {
                    // No images have been generated before
                    // So generate all images including static ones
                    return .merge(
                        Effect(value: Action.generateMapImage),
                        Effect(value: Action.generateChargerImage),
                        Effect(value: Action.generateForbiddenZones),
                        Effect(value: Action.generatePathImage),
                        Effect(value: Action.generateRobotImage),
                        Effect(value: Action.generateSegmentLabelsImage)
                    )
                }
            case .failure(let error):
                print("\(error.localizedDescription)")
            }

        case .refreshMapImage:
            return environment.rrFileParser.refreshData()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.setMapData)

        case .setFanspeed(let fanspeed):
            return environment.apiClient.setFanspeed(ApiId(), fanspeed)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.setFanspeedResponse)
            
        case .toggleRoom(let roomId):
            if let index = state.rooms.firstIndex(of: roomId) {
                state.rooms.remove(at: index)
            } else {
                state.rooms.append(roomId)
            }
            environment.rrFileParser.segments = state.rooms
            return Effect(value: .refreshMapImage)
            
        case .resetRooms:
            state.rooms = []
            environment.rrFileParser.segments = state.rooms
            return Effect(value: .refreshMapImage)

        case .generateMapImage:
            return environment.rrFileParser.drawMapImage()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.setMapImage)

        case .generatePathImage:
            return environment.rrFileParser.drawPathsImage()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.setPathImage)

        case .generateForbiddenZones:
            return environment.rrFileParser.drawForbiddenZonesImage()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.setForbiddenZonesImage)

        case .generateRobotImage:
            return environment.rrFileParser.drawRobotImage()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.setRobotImage)

        case .generateChargerImage:
            return environment.rrFileParser.drawChargerImage()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.setChargerImage)

        case .generateSegmentLabelsImage:
            return environment.rrFileParser.drawSegmentLabelsImage()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.setSegmentLabelsImage)

        case .setMapImage(let result):
            switch result {
            case .success(let image):
                state.mapImage = image
            case .failure(let error):
                print(error.localizedDescription)
            }

        case .setPathImage(let result):
            switch result {
            case .success(let image):
                state.pathImage = image
            case .failure(let error):
                print(error.localizedDescription)
            }

        case .setForbiddenZonesImage(let result):
            switch result {
            case .success(let image):
                state.forbiddenZonesImage = image
            case .failure(let error):
                print(error.localizedDescription)
            }

        case .setRobotImage(let result):
            switch result {
            case .success(let image):
                state.robotImage = image
            case .failure(let error):
                print(error.localizedDescription)
            }

        case .setChargerImage(let result):
            switch result {
            case .success(let image):
                state.chargerImage = image
            case .failure(let error):
                print(error.localizedDescription)
            }

        case .setSegmentLabelsImage(let result):
            switch result {
            case .success(let image):
                state.segmentLabelsImage = image
            case .failure(let error):
                print(error.localizedDescription)
            }
        default:
            break
        }
        return .none
    }
    
    static let initialState = State()
    
    static let previewState = State()
}
