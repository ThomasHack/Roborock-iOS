//
//  Response.swift
//  Roborock
//
//  Created by Thomas Hack on 13.05.21.
//

import Foundation

public enum Response: Decodable {
    case status(Status)
    case unknown

    enum CodingKeys: String, CodingKey {
        case status
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Status.self, forKey: .status)
        self = .status(data)
    }
}

public struct StatusUpdate: Decodable {
    public let status: Status

    enum CodingKeys: String, CodingKey {
        case status
    }
}
