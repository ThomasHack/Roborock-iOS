//
//  MapData.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.06.21.
//

import UIKit

public struct MapData: Equatable {
    public var meta: Meta?
    public var blocks: [Blocktype: Data] = [:]
    public var robotPosition: RobotPosition?
    public var chargerLocation: Point?
    public var image: UIImage?
    public var imageData: ImageData?
    public var vacuumPath: Path?
    public var gotoPath: Path?
    public var gotoPredictedPath: Path?
    public var forbiddenZones: ForbiddenZones?

    public init(meta: Meta? = nil, blocks: [Blocktype: Data] = [:], robotPosition: RobotPosition? = nil, chargerLocation: Point? = nil, image: UIImage? = nil, imageData: ImageData? = nil, vacuumPath: Path? = nil, gotoPath: Path? = nil, gotoPredictedPath: Path? = nil, forbiddenZones: ForbiddenZones? = nil) {
        self.meta = meta
        self.blocks = blocks
        self.robotPosition = robotPosition
        self.chargerLocation = chargerLocation
        self.image = image
        self.imageData = imageData
        self.vacuumPath = vacuumPath
        self.gotoPath = gotoPath
        self.gotoPredictedPath = gotoPredictedPath
        self.forbiddenZones = forbiddenZones
    }
}
