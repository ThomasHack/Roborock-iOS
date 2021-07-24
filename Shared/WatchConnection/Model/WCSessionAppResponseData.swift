//
//  WatchKitTransferData.swift
//  WatchKitTransferData
//
//  Created by Hack, Thomas on 23.07.21.
//

import Foundation

public struct WCSessionAppResponseData: Codable {
    var host: String

    enum CodingKeys: String, CodingKey {
        case host
    }

    public init(host: String) {
        self.host = host
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.host = try container.decode(String.self, forKey: .host)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(host, forKey: .host)
    }
}
