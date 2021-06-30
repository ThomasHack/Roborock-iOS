//
//  UIColor+PixelData.swift
//  Roborock
//
//  Created by Hack, Thomas on 28.06.21.
//

import UIKit

extension UIColor {
    var toPixel: MapData.Pixel {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return MapData.Pixel(r: UInt8(max(0, min(255, red * 255))),
                         g: UInt8(max(0, min(255, green * 255))),
                         b: UInt8(max(0, min(255, blue * 255))),
                         a: UInt8(max(0, min(255, alpha * 255))))
    }
}
