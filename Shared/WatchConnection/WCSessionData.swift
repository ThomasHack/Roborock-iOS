//
//  WatchKitTransferData.swift
//  WatchKitTransferData
//
//  Created by Hack, Thomas on 23.07.21.
//

import Foundation

public enum WCSessionData: Codable {
    case requestData(WCSessionRequestData)
    case responseAppData(WCSessionAppResponseData)
    case responseWatchData(WCSessionWatchResponseData)

    enum CodingKeys: String, CodingKey {
        case requestData
        case responseAppData
        case responseWatchData
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let data = try? container.decode(WCSessionRequestData.self, forKey: .requestData) {
            self = .requestData(data)
        } else if let data = try? container.decode(WCSessionAppResponseData.self, forKey: .responseAppData) {
            self = .responseAppData(data)
        } else if let data = try? container.decode(WCSessionWatchResponseData.self, forKey: .responseAppData) {
            self = .responseWatchData(data)
        } else {
            throw DecodingError.keyNotFound(CodingKeys.requestData, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: ""))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .requestData(let data):
            try container.encode(data, forKey: .requestData)
        case .responseAppData(let data):
            try container.encode(data, forKey: .responseAppData)
        case .responseWatchData(let data):
            try container.encode(data, forKey: .responseWatchData)
        }
    }
}
