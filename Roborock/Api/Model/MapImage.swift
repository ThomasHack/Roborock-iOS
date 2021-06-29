//
//  MapData.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.06.21.
//

import Foundation

extension MapData {
    struct MapImage {
        var segments: Segments
        var position: Position
        var dimensions: Dimensions
        var box: Box
        var pixels: [Int: Int]

        struct Center {
            var x: Int
            var y: Int
            var count: Int
        }

        struct Segments {
            var count: Int
            var center: [Int: Center]
            var borders: [Int]
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
            var minX: Int
            var minY: Int
            var maxX: Int
            var maxY: Int
        }
    }

}
