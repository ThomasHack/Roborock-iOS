//
//  UIColor+RGBA.swift
//  Roborock
//
//  Created by Hack, Thomas on 28.06.21.
//

import UIKit

extension UIColor
{
    /**
     Returns the components that make up the color in the RGB color space as a tuple.

     - returns: The RGB components of the color or `nil` if the color could not be converted to RGBA color space.
     */
    func getRGBAComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)?
    {
        var (red, green, blue, alpha) = (CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.0))
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        {
            return (red, green, blue, alpha)
        }
        else
        {
            return nil
        }
    }
    
    
}

extension UIColor {
    var toRgba: (r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (r: UInt8(max(0, min(255, red * 255))),
                g: UInt8(max(0, min(255, green * 255))),
                b: UInt8(max(0, min(255, blue * 255))),
                a: UInt8(max(0, min(255, alpha * 255))))
    }
}
