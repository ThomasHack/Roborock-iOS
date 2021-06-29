//
//  MapData.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.06.21.
//

import Foundation

struct MapMetaData {
    var headerLength: Int
    var dataLength: Int
    // var version: Version
    var mapIndex: Int
    var mapSequence: Int
}

struct MapData {
    var robotPosition: RobotPosition?
    var chargerLocation: ChargerLocation?
    var image: MapImage?
    var gotoPredictedPath: Path?
}
