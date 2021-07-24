//
//  WatchKitTransferData.swift
//  WatchKitTransferData
//
//  Created by Hack, Thomas on 23.07.21.
//

import Foundation

public struct WCSessionWatchResponseData: Codable {
    var placeholder: String

    enum CodingKeys: String, CodingKey {
        case placeholder
    }

    public init(placeholder: String) {
        self.placeholder = placeholder
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.placeholder = try container.decode(String.self, forKey: .placeholder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(placeholder, forKey: .placeholder)
    }
}
