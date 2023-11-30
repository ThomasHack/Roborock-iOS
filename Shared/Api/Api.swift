//
//  Api.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import ComposableArchitecture
import RoborockApi
import UIKit

struct ApiId: Hashable {}

@Reducer
struct Api {
    @Dependency(\.restClient) var restClient
    #if os(iOS)
    @Dependency(\.rrFileParser) var rrFileParser
    #endif

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .connectRest:
                guard let host = state.host,
                      let url = URL(string: "https://\(host)") else { return .none }
                restClient.connect(url)
                return .send(.fetchSegments)

            case .connectWebsocket:
                guard let host = state.host,
                      let url = URL(string: "wss://\(host)") else { return .none }
                return .send(.webSocket(.connect(url)))

            case .disconnectWebsocket:
                return .send(.webSocket(.disconnect))

            case .didConnect:
                state.connectivityState = .connected

            case .didDisconnect:
                state.connectivityState = .disconnected
                return .send(.resetState)

            case .didUpdateStatus(let status):
                state.status = status

            case .fetchSegments:
                return .run { send in
                    let segments = try await restClient.fetchSegments()
                    await send(.fetchSegmentsResponse(segments))
                } catch: { error, _ in
                    print(error.localizedDescription)
                }

            case .fetchSegmentsResponse(let segments):
                state.segments = segments
                return .send(.connectWebsocket)

            case .startCleaningSegment:
                let requestData = SegmentsRequestData(segments: state.rooms, repeats: 1, order: 1)
                return .run { _ in
                    _ = try await restClient.cleanSegments(requestData)
                } catch: { error, _ in
                    print(error.localizedDescription)
                }

            case .stopCleaning:
                return .run { send in
                    _ = try await restClient.stopCleaning()
                    await send(.resetRooms)
                } catch: { error, _ in
                    print(error.localizedDescription)
                }

            case .pauseCleaning:
                return .run { _ in
                    _ = try await restClient.pauseCleaning()
                } catch: { error, _ in
                    print(error.localizedDescription)
                }

            case .driveHome:
                return .run { _ in
                    _ = try await restClient.driveHome()
                } catch: { error, _ in
                    print(error.localizedDescription)
                }

            case .setFanspeed(let fanspeed):
                let requestData = FanspeedRequestData(speed: fanspeed.rawValue)
                return .run { _ in
                    _ = try await restClient.setFanspeed(requestData)
                } catch: { error, _ in
                    print(error.localizedDescription)
                }

    #if os(iOS)
            case .toggleRoom(let roomId):
                if let index = state.rooms.firstIndex(of: roomId) {
                    state.rooms.remove(at: index)
                } else {
                    state.rooms.append(roomId)
                }
                rrFileParser.segments = state.rooms
                return .send(.refreshMapImage)

            case .resetRooms:
                state.rooms = []
                rrFileParser.segments = state.rooms
                return .send(.refreshMapImage)

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
                return .run { send in
                    let image = try rrFileParser.drawMapImage()
                    await send(.setMapImage(image))
                }

            case .refreshMapImage:
                return .run { send in
                    let data = rrFileParser.refreshData()
                    await send(.setMapData(data))
                }

            case .generatePathImage:
                return .run { send in
                    let image = try rrFileParser.drawPathsImage()
                    await send(.setPathImage(image))
                }

            case .generateForbiddenZones:
                return .run { send in
                    let image = try rrFileParser.drawForbiddenZonesImage()
                    await send(.setForbiddenZonesImage(image))
                }

            case .generateRobotImage:
                return .run { send in
                    let image = try rrFileParser.drawRobotImage()
                    await send(.setRobotImage(image))
                }

            case .generateChargerImage:
                return .run { send in
                    let image = try rrFileParser.drawChargerImage()
                    await send(.setChargerImage(image))
                }

            case .generateSegmentLabelsImage:
                guard let segments = state.segments else { return .none }
                return .run { send in
                    let image = try rrFileParser.drawSegmentLabelsImage(segments)
                    await send(.setSegmentLabelsImage(image))
                }

            case .setMapData(let mapData):
                state.mapData = mapData
                if state.initialUpdateDone {
                    // Static images have been generated already
                    // So just update the changed ones
                    return .run { send in
                        await send(.generateMapImage)
                        await send(.generatePathImage)
                        await send(.generateRobotImage)
                    }
                } else {
                    // No images have been generated before
                    // So generate all images including static ones
                    return .run { send in
                        await send(.generateMapImage)
                        await send(.generateChargerImage)
                        await send(.generateForbiddenZones)
                        await send(.generatePathImage)
                        await send(.generateRobotImage)
                        await send(.generateSegmentLabelsImage)
                    }
                }

            case .setMapImage(let image):
                state.mapImage = image

            case .setPathImage(let image):
                state.pathImage = image

            case .setForbiddenZonesImage(let image):
                state.forbiddenZonesImage = image

            case .setRobotImage(let image):
                state.robotImage = image

            case .setChargerImage(let image):
                state.chargerImage = image

            case .setSegmentLabelsImage(let image):
                state.segmentLabelsImage = image

            case .webSocket(.receivedSocketMessage(let message)):
                return .run { send in
                    if case let .string(string) = message {
                        guard let data = string.data(using: .utf8, allowLossyConversion: true) else { return }
                        let response = try JSONDecoder().decode(Response.self, from: data)
                        if case let .status(status) = response {
                            await send(.didUpdateStatus(status))
                        }
                    }
                    if case let .data(data) = message {
                        let mapData = try rrFileParser.parse(data)
                        return await send(.setMapData(mapData))
                    }
                }
    #endif

    #if os(watchOS)
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

            case .webSocket(.receivedSocketMessage(let message)):
                return .run { send in
                    if case let .string(string) = message {
                        guard let data = string.data(using: .utf8, allowLossyConversion: true) else { return }
                        let response = try JSONDecoder().decode(Response.self, from: data)
                        if case let .status(status) = response {
                            await send(.didUpdateStatus(status))
                        }
                    }
                }
    #endif

            case .webSocket:
                break
            }
            return .none
        }
        Scope(state: \.webSocket, action: /Action.webSocket) {
            WebSocket()
        }
    }

    static let initialState = State()

    static let segments = [
        Segment(id: 1, name: "Wohnzimmer"),
        Segment(id: 2, name: "Arbeitszimmer"),
        Segment(id: 3, name: "Schlafzimmer"),
        Segment(id: 4, name: "Küche")
    ]

    static let status = Status(
        state: 8,
        otaState: "",
        messageVersion: 1,
        battery: 86,
        cleanTime: 60,
        cleanArea: 10,
        errorCode: 0,
        mapPresent: 1,
        inCleaning: 0,
        inReturning: 0,
        inFreshState: 1,
        waterBoxStatus: 0,
        fanPower: 101,
        dndEnabled: 0,
        mapStatus: 1,
        mainBrushLife: 100,
        sideBrushLife: 200,
        filterLife: 300,
        stateHumanReadable: "Charging",
        model: "roborock.s5",
        errorHumanReadable: ""
    )

    static let previewState = State(
        connectivityState: .connecting,
        segments: Segments(segment: segments),
        rooms: [],
        status: status
    )

    static let previewStore = Store(initialState: previewState) {
        Api()
    }
}
