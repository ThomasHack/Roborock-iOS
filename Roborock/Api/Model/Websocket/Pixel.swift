//
//  Pixel.swift
//  Roborock
//
//  Created by Thomas Hack on 30.06.21.
//

import Foundation

extension MapData {
    struct Pixel: Equatable {
        var r: UInt8
        var g: UInt8
        var b: UInt8
        var a: UInt8 = 255
    }
}
