//
//  WatchKitSessionClient+Dependency.swift
//  Roborock
//
//  Created by Hack, Thomas on 11.03.23.
//

import ComposableArchitecture

extension WatchKitSessionClient: DependencyKey {
    public static let liveValue = WatchKitSessionClient.live
}

extension DependencyValues {
  var watchkitSessionClient: WatchKitSessionClient {
    get { self[WatchKitSessionClient.self] }
    set { self[WatchKitSessionClient.self] = newValue }
  }
}
