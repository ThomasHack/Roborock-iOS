//
//  RobotPosition.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.06.21.
//

import UIKit

extension MapData {
    struct RobotPosition: Equatable {
        var position: Point
        var angle: Int?
    }
}
