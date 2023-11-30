//
//  WatchKitTransferData.swift
//  WatchKitTransferData
//
//  Created by Hack, Thomas on 23.07.21.
//

import Foundation

public struct WCSessionRequestData: Equatable, Codable {
    var action: WCSessionAction

    enum CodingKeys: String, CodingKey {
        case action
    }

    public init(action: WCSessionAction) {
        self.action = action
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.action = try container.decode(WCSessionAction.self, forKey: .action)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(action.rawValue, forKey: .action)
    }
}
