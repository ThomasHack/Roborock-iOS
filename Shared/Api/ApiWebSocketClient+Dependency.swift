//
//  ApiWebSocketClient+Dependency.swift
//  Roborock
//
//  Created by Hack, Thomas on 11.03.23.
//

import ComposableArchitecture
import RoborockApi

extension ApiWebSocketClient: DependencyKey {
    public static let liveValue = ApiWebSocketClient.live
}

extension DependencyValues {
  var websocketClient: ApiWebSocketClient {
    get { self[ApiWebSocketClient.self] }
    set { self[ApiWebSocketClient.self] = newValue }
  }
}
