//
//  Path.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.06.21.
//

import UIKit

extension MapData {
    struct Path: Equatable {
        var currentAngle: Int
        var points: [Point]
    }
}
