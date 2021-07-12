//
//  Api+Action.swift
//  Roborock
//
//  Created by Hack, Thomas on 12.07.21.
//

import ComposableArchitecture
import RoborockApi
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

        case fetchSegmentsResponse(Result<Segments, ApiRestClient.Failure>)

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
}
