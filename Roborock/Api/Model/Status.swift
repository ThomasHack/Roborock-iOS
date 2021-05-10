//
//  Status.swift
//  Roborock
//
//  Created by Thomas Hack on 08.05.21.
//

import Foundation

struct Status: Equatable, Decodable {
    var battery: Int
    var cleanTime: Int
    var cleanArea: Int
    var inCleaning: Int
    var inReturning: Int
    var humanState: String
    
    enum CodingKeys: String, CodingKey {
        case battery = "battery"
        case cleanTime = "clean_time"
        case cleanArea = "clean_area"
        case inCleaning = "in_cleaning"
        case inReturning = "in_returning"
        case humanState = "human_state"
    }
}
