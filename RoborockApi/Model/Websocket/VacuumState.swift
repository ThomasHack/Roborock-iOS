//
//  VacuumState.swift
//  Roborock
//
//  Created by Hack, Thomas on 06.07.21.
//

import Foundation

public enum VacuumState: Int {
    case unknown = 0
    case initiating = 1
    case sleeping = 2
    case idle = 3
    case remoteControl = 4
    case cleaning = 5
    case returningDock = 6
    case manualMode = 7
    case charging = 8
    case charginError = 9
    case paused = 10
    case spotCleaning = 11
    case inError = 12
    case shuttingDown = 13
    case updating = 14
    case docking = 15
    case goto = 16
    case zoneClean = 17
    case roomClean = 18
    case fullyCharged = 100
}
