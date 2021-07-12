//
//  Status.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import Foundation

public struct Status: Equatable, Decodable {
    public var state: Int
    public var otaState: String
    public var messageVersion: Int
    public var battery: Int
    public var cleanTime: Int
    public var cleanArea: Int
    public var errorCode: Int
    public var mapPresent: Int
    public var inCleaning: Int
    public var inReturning: Int
    public var inFreshState: Int
    public var waterBoxStatus: Int
    public var fanPower: Int
    public var dndEnabled: Int
    public var mapStatus: Int
    public var mainBrushLife: Int
    public var sideBrushLife: Int
    public var filterLife: Int
    public var stateHumanReadable: String
    public var model: String
    public var errorHumanReadable: String

    public var vacuumState: VacuumState? {
        VacuumState(rawValue: state)
    }

    public init(state: Int, otaState: String, messageVersion: Int, battery: Int, cleanTime: Int, cleanArea: Int, errorCode: Int, mapPresent: Int, inCleaning: Int, inReturning: Int, inFreshState: Int, waterBoxStatus: Int, fanPower: Int, dndEnabled: Int, mapStatus: Int, mainBrushLife: Int, sideBrushLife: Int, filterLife: Int, stateHumanReadable: String, model: String, errorHumanReadable: String) {
        self.state = state
        self.otaState = otaState
        self.messageVersion = messageVersion
        self.battery = battery
        self.cleanTime = cleanTime
        self.cleanArea = cleanArea
        self.errorCode = errorCode
        self.mapPresent = mapPresent
        self.inCleaning = inCleaning
        self.inReturning = inReturning
        self.inFreshState = inFreshState
        self.waterBoxStatus = waterBoxStatus
        self.fanPower = fanPower
        self.dndEnabled = dndEnabled
        self.mapStatus = mapStatus
        self.mainBrushLife = mainBrushLife
        self.sideBrushLife = sideBrushLife
        self.filterLife = filterLife
        self.stateHumanReadable = stateHumanReadable
        self.model = model
        self.errorHumanReadable = errorHumanReadable
    }

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
}
