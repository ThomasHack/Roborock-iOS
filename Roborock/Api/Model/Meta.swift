//
//  Meta.swift
//  Roborock
//
//  Created by Hack, Thomas on 30.06.21.
//

import Foundation

extension MapData {
    struct Meta {
        var headerLength: Int
        var dataLength: Int
        var version: Version
        var mapIndex: Int
        var mapSequence: Int

        struct Version {
            var major: Int
            var minor: Int
        }
    }
}
