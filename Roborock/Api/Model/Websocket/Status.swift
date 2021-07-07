//
//  Status.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import Foundation

public struct Status: Equatable, Decodable {
    var state: Int
    var otaState: String
    var messageVersion: Int
    var battery: Int
    var cleanTime: Int
    var cleanArea: Int
    var errorCode: Int
    var mapPresent: Int
    var inCleaning: Int
    var inReturning: Int
    var inFreshState: Int
    var waterBoxStatus: Int
    var fanPower: Int
    var dndEnabled: Int
    var mapStatus: Int
    var mainBrushLife: Int
    var sideBrushLife: Int
    var filterLife: Int
    var stateHumanReadable: String
    var model: String
    var errorHumanReadable: String
    
    enum CodingKeys: String, CodingKey {
        case state = "state"
        case otaState = "ota_state"
        case messageVersion = "msg_ver"
        case battery = "battery"
        case cleanTime = "clean_time"
        case cleanArea = "clean_area"
        case errorCode = "error_code"
        case mapPresent = "map_present"
        case inCleaning = "in_cleaning"
        case inReturning = "in_returning"
        case inFreshState = "in_fresh_state"
        case waterBoxStatus = "water_box_status"
        case fanPower = "fan_power"
        case dndEnabled = "dnd_enabled"
        case mapStatus = "map_status"
        case mainBrushLife = "main_brush_life"
        case sideBrushLife = "side_brush_life"
        case filterLife = "filter_life"
        case stateHumanReadable = "stateHR"
        case model = "model"
        case errorHumanReadable = "errorHR"
    }

    var vacuumState: VacuumState? {
        return VacuumState(rawValue: state)
    }
}
