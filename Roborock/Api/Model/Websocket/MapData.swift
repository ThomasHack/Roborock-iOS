//
//  MapData.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.06.21.
//

import UIKit

struct MapData: Equatable {
    var meta: Meta?
    var robotPosition: RobotPosition?
    var chargerLocation: Point?
    var image: UIImage?
    var imageData: ImageData?
    var vacuumPath: Path?
    var gotoPath: Path?
    var gotoPredictedPath: Path?
}
