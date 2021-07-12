//
//  Point.swift
//  Roborock
//
//  Created by Thomas Hack on 30.06.21.
//

import Foundation

extension MapData {
    public struct Point: Equatable {
        public var x: Int
        public var y: Int

        public init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
    }
}
