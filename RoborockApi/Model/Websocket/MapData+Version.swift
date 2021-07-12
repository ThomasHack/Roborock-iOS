//
//  Version.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.06.21.
//

import Foundation

extension MapData {
    public struct Version: Equatable {
        public var major: Int
        public var minor: Int

        public init(major: Int, minor: Int) {
            self.major = major
            self.minor = minor
        }
    }
}
