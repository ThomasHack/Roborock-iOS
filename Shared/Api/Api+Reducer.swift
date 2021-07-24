//
//  Api+Reducer.swift
//  Roborock
//
//  Created by Hack, Thomas on 12.07.21.
//

import ComposableArchitecture
import RoborockApi
import UIKit

extension Api {
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .connect(let url):
            return environment.websocketClient.connect(ApiId(), url)
                .receive(on: environment.mainQueue)
                .eraseToEffect()

        case .connectRest(let url):
            environment.restClient.connect(url)
            return .none

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

        case .didUpdateStatus(let status):
            state.status = status

        case .fetchSegments:
            return environment.restClient.fetchSegments()
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
            let requestData = SegmentsRequestData(segments: state.rooms, repeats: 1, order: 1)
            return environment.restClient.cleanSegments(requestData)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.startCleaningSegmentResponse)

        case .startCleaningSegmentResponse(let result):
            switch result {
            case .success:
                print("result: \(result)")
            case .failure(let error):
                print(error.localizedDescription)
            }
            return .none

        case .stopCleaning:
            return environment.restClient.stopCleaning()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.stopCleaningResponse)

        case .stopCleaningResponse(let result):
            switch result {
            case .success:
                print("result: \(result)")
                return Effect(value: .resetRooms)
            case .failure(let error):
                print(error.localizedDescription)
            }
            return .none

        case .pauseCleaning:
            return environment.restClient.pauseCleaning()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.pauseCleaningResponse)

        case .pauseCleaningResponse(let result):
            switch result {
            case .success:
                print("result: \(result)")
            case .failure(let error):
                print(error.localizedDescription)
            }
            return .none

        case .driveHome:
            return environment.restClient.driveHome()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.driveHomeResponse)

        case .driveHomeResponse(let result):
            switch result {
            case .success:
                print("result: \(result)")
            case .failure(let error):
                print(error.localizedDescription)
            }
            return .none

        case .setFanspeed(let fanspeed):
            let requestData = FanspeedRequestData(speed: fanspeed.rawValue)
            return environment.restClient.setFanspeed(requestData)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.setFanspeedResponse)

        case . setFanspeedResponse(let result):
            print("result: \(result)")

#if os(iOS)
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
            return environment.rrFileParser.drawMapImage()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.setMapImage)

        case .refreshMapImage:
            return environment.rrFileParser.refreshData()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.setMapData)

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
