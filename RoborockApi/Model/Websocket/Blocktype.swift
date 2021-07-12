//
//  Blocktype.swift
//  Roborock
//
//  Created by Hack, Thomas on 01.07.21.
//

import Foundation

extension MapData {
    public enum Blocktype: Int {
        case chargerLocation = 1
        case image = 2
        case path = 3
        case gotoPath = 4
        case gotoPredictedPath = 5
        case currentlyCleanedZones = 6
        case gotoTarget = 7
        case robotPosition = 8
        case forbiddenZones = 9
        case virtualWalls = 10
        case currentlyCleanedBlocks = 11
        case forbiddenMopZones = 12
        case digest = 1024
    }
}
