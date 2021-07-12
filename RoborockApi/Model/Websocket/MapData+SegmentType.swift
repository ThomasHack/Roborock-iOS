//
//  SegmentType.swift
//  Roborock
//
//  Created by Thomas Hack on 03.07.21.
//

import Foundation

extension MapData {
    public enum SegmentType: Int {
        case studio = 16
        case bath = 19
        case bedroom = 21
        case corridor = 22
        case kitchen = 23
        case livingroom = 17
        case toilet = 20
        case supply = 18

        public var label: String {
            switch self {
            case .studio:
                return "Studio"
            case .bath:
                return "Badezimmer"
            case .bedroom:
                return "Schlafzimmer"
            case .corridor:
                return "Flur"
            case .kitchen:
                return "Küche"
            case .livingroom:
                return "Wohnzimmer"
            case .toilet:
                return "Toilette"
            case .supply:
                return "Vorrat"
            }
        }
    }
}
