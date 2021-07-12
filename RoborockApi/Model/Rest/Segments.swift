//
//  Segment.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import Foundation

public struct Segments: Equatable, Decodable, Hashable {
    public let data: [Segment]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        data = try container.decode([Segment].self)
    }

    public init(segment: [Segment]) {
        self.data = segment
    }
}

public struct Segment: Equatable, Decodable, Hashable {
    public let id: Int
    public let name: String

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.id = try container.decode(Int.self)
        self.name = try container.decode(String.self)
    }

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
