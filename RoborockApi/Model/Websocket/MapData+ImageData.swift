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

        public init(segments: Segments, position: Position, dimensions: Size, pixels: [Pixel], data: Data? = nil) {
            self.segments = segments
            self.position = position
            self.dimensions = dimensions
            self.data = data
            self.pixels = pixels
        }
    }
}
