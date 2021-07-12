//
//  ImageData.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.06.21.
//

import UIKit

extension MapData {
    public struct ImageData: Equatable {
        public var segments: Segments
        public var position: Position
        public var dimensions: Size
        public var data: Data?
        public var pixels: [Pixel]

        public init(segments: Segments, position: Position, dimensions: Size, data: Data? = nil, pixels: [Pixel]) {
            self.segments = segments
            self.position = position
            self.dimensions = dimensions
            self.data = data
            self.pixels = pixels
        }

        public struct Center: Equatable {
            public var position: Point
            public var count: Int

            public init(position: Point, count: Int) {
                self.position = position
                self.count = count
            }
        }

        public struct Segments: Equatable {
            public var count: Int
            public var center: [Int: Center]

            public init(count: Int, center: [Int: Center]) {
                self.count = count
                self.center = center
            }
        }
    }

}
