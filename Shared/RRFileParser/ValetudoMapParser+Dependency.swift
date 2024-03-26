//
//  ValetudoMapParser+Dependency.swift
//  Roborock
//
//  Created by Hack, Thomas on 24.02.24.
//

import ComposableArchitecture
import Foundation

extension ValetudoMapParser: DependencyKey {
    public static let liveValue = ValetudoMapParser.live
}

extension DependencyValues {
  var valetudoMapParser: ValetudoMapParser {
    get { self[ValetudoMapParser.self] }
    set { self[ValetudoMapParser.self] = newValue }
  }
}
