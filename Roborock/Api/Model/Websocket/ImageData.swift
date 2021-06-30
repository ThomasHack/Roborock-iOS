//
//  ImageData.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.06.21.
//

import UIKit

extension MapData {
    struct ImageData: Equatable {
        var segments: Segments
        var position: Position
        var dimensions: Dimensions
        var box: Box
        var data: Data?
        var pixels: [Pixel]

        struct Data: Equatable {
            var floor: [CGPoint]
            var obstacleWeak: [CGPoint]
            var obstacleStrong: [CGPoint]
        }

        struct Center: Equatable {
            var position: CGPoint
            var count: Int
        }

        struct Segments: Equatable {
            var count: Int
            var center: [Int: Center]
            var borders: [Double]
            var neighbours: [Int: Bool]
        }

        struct Position: Equatable {
            var top: Int
            var left: Int
        }

        struct Dimensions: Equatable {
            var height: Int
            var width: Int
        }

        struct Box: Equatable {
            var minX: Double
            var minY: Double
            var maxX: Double
            var maxY: Double
        }
    }

}
