//
//  Api+Action.swift
//  Roborock
//
//  Created by Hack, Thomas on 12.07.21.
//

import ComposableArchitecture
import Roborock_Api
import UIKit

extension Api {
    enum Action: Equatable {
        case connect(URL)
        case didConnect
        case disconnect
        case didDisconnect
        case resetState
        case didReceiveWebSocketEvent(ApiWebSocketEvent)
        case didUpdateStatus(Status)

        case fetchSegments

        case fetchSegmentsResponse(Result<Segments, RestClientError>)

        case startCleaningSegment
        case startCleaningSegmentResponse(Result<String, RestClientError>)
        case stopCleaning
        case stopCleaningResponse(Result<String, RestClientError>)
        case pauseCleaning
        case pauseCleaningResponse(Result<String, RestClientError>)

        case driveHome
        case driveHomeResponse(Result<String, RestClientError>)

        case refreshMapImage

        case setFanspeed(Int)
        case setFanspeedResponse(Result<String, RestClientError>)

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
}
