//
//  Fanspeed.swift
//  Roborock
//
//  Created by Hack, Thomas on 02.07.21.
//

import Foundation

public enum Fanspeed: Int, Equatable, CaseIterable {
    case quiet = 101
    case balanced = 102
    case turbo = 103
    case max = 104
    case mop = 105

    public var label: String {
        switch self {
        case .quiet:
            return "Quiet"
        case .balanced:
            return "Balanced"
        case .turbo:
            return "Turbo"
        case .max:
            return "Max"
        case .mop:
            return "Mop"
        }
    }
}
