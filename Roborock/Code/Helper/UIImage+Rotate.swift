//
//  UIImage+Rotate.swift
//  Roborock
//
//  Created by Hack, Thomas on 28.06.21.
//

import UIKit

extension UIImage {
    func rotate(angle: Float) -> UIImage? {
        // var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(angle))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        // newSize.width = floor(newSize.width)
        // newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: self.size.width/2, y: self.size.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(angle * .pi / 180))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
