//
//  Segment.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import Foundation

struct Segment: Equatable, Decodable, Hashable {
    let data: [SegmentValue]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        data = try container.decode([SegmentValue].self)
    }
    
    init(segment: [SegmentValue]) {
        self.data = segment
    }
}

struct SegmentValue: Equatable, Decodable, Hashable {
    let id: Int?
    let name: String?
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.id = try? container.decode(Int.self)
        self.name = try? container.decode(String.self)
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
