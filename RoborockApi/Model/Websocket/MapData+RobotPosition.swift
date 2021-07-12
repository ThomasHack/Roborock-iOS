//
//  RobotPosition.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.06.21.
//

import UIKit

extension MapData {
    public struct RobotPosition: Equatable {
        public var position: Point
        public var angle: Int?

        public init(position: Point, angle: Int? = nil) {
            self.position = position
            self.angle = angle
        }
    }
}
