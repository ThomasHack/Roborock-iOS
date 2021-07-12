//
//  ApiWebSocketEvent.swift
//  Roborock
//
//  Created by Thomas Hack on 13.05.21.
//

import Foundation

public enum ApiWebSocketEvent: Equatable {
    case connected              // case connected([String: String])
    case disconnected           // case disconnected(String, UInt16)
    case text(String)           // case text(String)
    case binary(Data)           // case binary(Data)
    case ping                   // case ping(Data?)
    case pong                   // case pong(Data?)
    // case viabilityChanged    // case viabilityChanged(Bool)
    // reconnectSuggested       // case reconnectSuggested(Bool)
    case cancelled              // case cancelled
    case error(NSError?)        // case error(Error?)
}
