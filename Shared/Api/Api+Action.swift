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
    @CasePathable
    enum Action: Equatable {
        case connect
        case disconnect
        case didConnect
        case didDisconnect
        case update
        case subscribe
        case subscribeState
        case unsubscribe
        case fetchInfo
        case fetchInfoResponse(RobotInfo)
        case fetchState
        case updateState([StateAttribute])
        case fetchCurrentStatistics
        case fetchCurrentStatisticsResponse([StatisticsDataPoint])
        case fetchTotalStatistics
        case fetchTotalStatisticsResponse([StatisticsDataPoint])
        case fetchSegments
        case fetchSegmentsResponse([Segment])
        case startCleaningSegment
        case stopCleaning
        case pauseCleaning
        case driveHome
        case controlFanSpeed(FanSpeedControlPreset)
        case controlWaterUsage(WaterUsageControlPreset)
        case toggleRoom(Segment)
        case resetRooms
        case resetState
        case eventClient(EventClient.Action)
        case alert(PresentationAction<Alert>)
        #if os(iOS) || os(tvOS) || os(visionOS)
        case fetchMap
        case subscribeMap
        case drawMapImage(Map)
        case redrawMapImage
        case drawEntityImages(Map)
        case updateMapImage(MapImage?)
        case updateEntityImages([MapImage])
        #endif

        @CasePathable
        enum Alert: Equatable {
            case apiError(String)
        }
    }
}
