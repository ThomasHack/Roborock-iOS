//
//  RRFileParser+Dependency.swift
//  Roborock
//
//  Created by Hack, Thomas on 11.03.23.
//

import ComposableArchitecture
import RoborockApi

extension RRFileParser: DependencyKey {
    public static let liveValue = RRFileParser.live
}

extension DependencyValues {
  var rrFileParser: RRFileParser {
    get { self[RRFileParser.self] }
    set { self[RRFileParser.self] = newValue }
  }
}
