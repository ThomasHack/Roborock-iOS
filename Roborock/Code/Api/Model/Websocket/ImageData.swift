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
        var dimensions: Size
        var data: Data?
        var pixels: [Pixel]

        struct Data: Equatable {
            var floor: [Point]
            var obstacleWeak: [Point]
            var obstacleStrong: [Point]
        }

        struct Center: Equatable {
            var position: Point
            var count: Int
        }

        struct Segments: Equatable {
            var count: Int
            var center: [Int: Center]
        }

        struct Box: Equatable {
            var minX: Int
            var minY: Int
            var maxX: Int
            var maxY: Int
        }
    }

}
