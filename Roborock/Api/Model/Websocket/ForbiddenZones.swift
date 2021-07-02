//
//  ForbiddenZone.swift
//  Roborock
//
//  Created by Hack, Thomas on 02.07.21.
//

import Foundation

extension MapData {
    struct ForbiddenZones: Equatable {
        var count: Int
        var zones: [[Point]]
    }
}
