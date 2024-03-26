//
//  LayerType+UIColor.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.02.24.
//

import RoborockApi
import UIKit

extension Map.Layer.LayerType {
    public var color: UIColor {
        switch self {
        case .floor:
            return .floorColor
        case .wall:
            return .obstacleColor
        case .segment:
            return .floorColor
        }
    }
}
