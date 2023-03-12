//
//  Api.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import RoborockApi
import UIKit

extension Api {
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .connect(let url):
                return websocketClient.connect(ApiId(), url)
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()

            case .connectRest(let url):
                restClient.connect(url)
                return .none

            case .didConnect:
                state.connectivityState = .connected
                return .merge(
                    EffectTask(value: .fetchSegments)
                )

            case .disconnect:
                return websocketClient.disconnect(ApiId())
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()

            case .didDisconnect:
                state.connectivityState = .disconnected
                return EffectTask(value: .resetState)

            case .didUpdateStatus(let status):
                state.status = status

            case .fetchSegments:
                return restClient.fetchSegments()
                    .receive(on: DispatchQueue.main)
                    .catchToEffect()
                    .map(Action.fetchSegmentsResponse)

            case .fetchSegmentsResponse(let response):
                switch response {
                case .success(let segments):
                    state.segments = segments
                case .failure(let error):
                    print(error.localizedDescription)
                }
                return .none

            case .startCleaningSegment:
                let requestData = SegmentsRequestData(segments: state.rooms, repeats: 1, order: 1)
                return restClient.cleanSegments(requestData)
                    .receive(on: DispatchQueue.main)
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
                return restClient.stopCleaning()
                    .receive(on: DispatchQueue.main)
                    .catchToEffect()
                    .map(Action.stopCleaningResponse)

            case .stopCleaningResponse(let result):
                switch result {
                case .success:
                    return EffectTask(value: .resetRooms)
                case .failure(let error):
                    print(error.localizedDescription)
                }
                return .none

            case .pauseCleaning:
                return restClient.pauseCleaning()
                    .receive(on: DispatchQueue.main)
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
                return restClient.driveHome()
                    .receive(on: DispatchQueue.main)
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

            case .setFanspeed(let fanspeed):
                let requestData = FanspeedRequestData(speed: fanspeed.rawValue)
                return restClient.setFanspeed(requestData)
                    .receive(on: DispatchQueue.main)
                    .catchToEffect()
                    .map(Action.setFanspeedResponse)

            case . setFanspeedResponse:
                break

    #if os(iOS)
            case .toggleRoom(let roomId):
                if let index = state.rooms.firstIndex(of: roomId) {
                    state.rooms.remove(at: index)
                } else {
                    state.rooms.append(roomId)
                }
                rrFileParser.segments = state.rooms
                return EffectTask(value: .refreshMapImage)

            case .resetRooms:
                state.rooms = []
                rrFileParser.segments = state.rooms
                return EffectTask(value: .refreshMapImage)

            case .didReceiveWebSocketEvent(let event):
                switch event {
                case .binary(let data):
                    return rrFileParser.parse(data)
                        .receive(on: DispatchQueue.main)
                        .catchToEffect()
                        .map(Action.setMapData)
                default:
                    break
                }

            case .resetState:
                state.status = nil
                state.rooms = []
                state.mapImage = nil
                state.pathImage = nil
                state.forbiddenZonesImage = nil
                state.robotImage = nil
                state.chargerImage = nil
                state.segmentLabelsImage = nil

            case .generateMapImage:
                return rrFileParser.drawMapImage()
                    .receive(on: DispatchQueue.main)
                    .catchToEffect()
                    .map(Action.setMapImage)

            case .refreshMapImage:
                return rrFileParser.refreshData()
                    .receive(on: DispatchQueue.main)
                    .catchToEffect()
                    .map(Action.setMapData)

            case .generatePathImage:
                return rrFileParser.drawPathsImage()
                    .receive(on: DispatchQueue.main)
                    .catchToEffect()
                    .map(Action.setPathImage)

            case .generateForbiddenZones:
                return rrFileParser.drawForbiddenZonesImage()
                    .receive(on: DispatchQueue.main)
                    .catchToEffect()
                    .map(Action.setForbiddenZonesImage)

            case .generateRobotImage:
                return rrFileParser.drawRobotImage()
                    .receive(on: DispatchQueue.main)
                    .catchToEffect()
                    .map(Action.setRobotImage)

            case .generateChargerImage:
                return rrFileParser.drawChargerImage()
                    .receive(on: DispatchQueue.main)
                    .catchToEffect()
                    .map(Action.setChargerImage)

            case .generateSegmentLabelsImage:
                guard let segments = state.segments else { return .none }
                return rrFileParser.drawSegmentLabelsImage(segments)
                    .receive(on: DispatchQueue.main)
                    .catchToEffect()
                    .map(Action.setSegmentLabelsImage)

            case .setMapData(let result):
                switch result {
                case .success(let mapData):
                    state.mapData = mapData
                    if state.initialUpdateDone {
                        // Static images have been generated already
                        // So just update the changed ones
                        return .merge(
                            EffectTask(value: Action.generateMapImage),
                            EffectTask(value: Action.generatePathImage),
                            EffectTask(value: Action.generateRobotImage)
                        )
                    } else {
                        // No images have been generated before
                        // So generate all images including static ones
                        return .merge(
                            EffectTask(value: Action.generateMapImage),
                            EffectTask(value: Action.generateChargerImage),
                            EffectTask(value: Action.generateForbiddenZones),
                            EffectTask(value: Action.generatePathImage),
                            EffectTask(value: Action.generateRobotImage),
                            EffectTask(value: Action.generateSegmentLabelsImage)
                        )
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }

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
    #endif

    #if os(watchOS)
            case .didReceiveWebSocketEvent:
                return .none

            case .toggleRoom(let roomId):
                if let index = state.rooms.firstIndex(of: roomId) {
                    state.rooms.remove(at: index)
                } else {
                    state.rooms.append(roomId)
                }
                return .none

            case .resetRooms:
                state.rooms = []
                return .none

            case .resetState:
                state.status = nil
                state.rooms = []
    #endif
            }
            return .none
        }
    }
}
