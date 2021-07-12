//
//  Size.swift
//  Roborock
//
//  Created by Thomas Hack on 30.06.21.
//

import Foundation

extension MapData {
    public struct Size: Equatable {
        public var width: Int
        public var height: Int

        public init(width: Int, height: Int) {
            self.width = width
            self.height = height
        }
    }
}
