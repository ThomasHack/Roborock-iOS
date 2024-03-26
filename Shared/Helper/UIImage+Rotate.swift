//
//  UIImage+Rotate.swift
//  Roborock
//
//  Created by Hack, Thomas on 28.06.21.
//

import UIKit

extension UIImage {
    func rotate(angle: Float) -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // Move origin to middle
        context.translateBy(x: self.size.width / 2, y: self.size.height / 2)
        // Rotate around middle
        context.rotate(by: CGFloat(angle * .pi / 180))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
