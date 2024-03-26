//
//  MapEntity+UIColor.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.02.24.
//

import RoborockApi
import UIKit

extension Map.Entity.EntityType {
    public var color: UIColor {
        switch self {
        case .activeZone:
            // TODO: Change color
            return .red
        case .chargerLocation:
            return .clear
        case .goToTarget:
            return .red
        case .noGoArea:
            return .forbiddenZoneBackground
        case .noMopArea:
            // TODO: Change color
            return .forbiddenZoneBackground
        case .path:
            // TODO: Change color
            return .white
        case .predictedPath:
            // TODO: Change color
            return .green
        case .robotPosition:
            return .clear
        case .virtualWall:
            return .forbiddenZoneStroke
        }
    }
}
