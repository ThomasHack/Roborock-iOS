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
    enum Action: Equatable {
        case connectRest
        case connectWebsocket
        case disconnectWebsocket
        case didConnect
        case didDisconnect
        case didUpdateStatus(Status)

        case fetchSegments
        case fetchSegmentsResponse(Segments)
        case startCleaningSegment
        case stopCleaning
        case pauseCleaning
        case driveHome
        case setFanspeed(Fanspeed)
        case toggleRoom(Int)
        case resetRooms
        case resetState

        case webSocket(WebSocket.Action)

#if os(iOS)
        case generateMapImage
        case refreshMapImage
        case generatePathImage
        case generateForbiddenZones
        case generateRobotImage
        case generateChargerImage
        case generateSegmentLabelsImage

        case setMapData(MapData)
        case setMapImage(UIImage)
        case setPathImage(UIImage)
        case setForbiddenZonesImage(UIImage)
        case setRobotImage(UIImage)
        case setChargerImage(UIImage)
        case setSegmentLabelsImage(UIImage)
#endif
    }
}
