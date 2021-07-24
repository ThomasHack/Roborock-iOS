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
        case connectRest(URL)
        case didConnect
        case disconnect
        case didDisconnect
        case didReceiveWebSocketEvent(ApiWebSocketEvent)
        case didUpdateStatus(Status)

        case fetchSegments
        case fetchSegmentsResponse(Result<Segments, RestClientError>)
        case startCleaningSegment
        case startCleaningSegmentResponse(Result<ResponseString, RestClientError>)
        case stopCleaning
        case stopCleaningResponse(Result<ResponseString, RestClientError>)
        case pauseCleaning
        case pauseCleaningResponse(Result<ResponseString, RestClientError>)
        case driveHome
        case driveHomeResponse(Result<ResponseString, RestClientError>)
        case setFanspeed(Fanspeed)
        case setFanspeedResponse(Result<ResponseString, RestClientError>)
        case toggleRoom(Int)
        case resetRooms
        case resetState

#if os(iOS)
        case generateMapImage
        case refreshMapImage
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
#endif
    }
}
