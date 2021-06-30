//
//  Image.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.06.21.
//

import UIKit

extension MapData {
    struct ImageData {
        var segments: Segments
        var position: Position
        var dimensions: Dimensions
        var box: Box
        var data: Data?
        var pixels: [PixelData]

        struct Data {
            var floor: [CGPoint]
            var obstacleWeak: [CGPoint]
            var obstacleStrong: [CGPoint]
        }

        struct Center {
            var x: Double
            var y: Double
            var count: Int
        }

        struct Segments {
            var count: Int
            var center: [Int: Center]
            var borders: [Double]
            var neighbours: [Int: Bool]
        }

        struct Position {
            var top: Int
            var left: Int
        }

        struct Dimensions {
            var height: Int
            var width: Int
        }

        struct Box {
            var minX: Double
            var minY: Double
            var maxX: Double
            var maxY: Double
        }
    }

}
