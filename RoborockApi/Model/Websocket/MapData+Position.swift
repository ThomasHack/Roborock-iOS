//
//  Position.swift
//  Roborock
//
//  Created by Thomas Hack on 30.06.21.
//

import Foundation

extension MapData {
    public struct Position: Equatable {
        public var top: Int
        public var left: Int

        public init(top: Int, left: Int) {
            self.top = top
            self.left = left
        }
    }
}
