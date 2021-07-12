//
//  Pixel.swift
//  Roborock
//
//  Created by Thomas Hack on 30.06.21.
//

import Foundation

extension MapData {
    public struct Pixel: Equatable {
        public var r: UInt8
        public var g: UInt8
        public var b: UInt8
        public var a: UInt8 = 255

        public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) {
            self.r = r
            self.g = g
            self.b = b
            self.a = a
        }
    }
}
