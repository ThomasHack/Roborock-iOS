//
//  MapData.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.06.21.
//

import UIKit

struct MapData {
    var meta: Meta?
    var robotPosition: RobotPosition?
    var chargerLocation: CGPoint?
    var image: ImageData?
    var vacuumPath: Path?
    var gotoPath: Path?
    var gotoPredictedPath: Path?
}
