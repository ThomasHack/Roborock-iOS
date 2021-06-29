//
//  RRFileParser.swift
//  Roborock
//
//  Created by Hack, Thomas on 28.06.21.
//

import Foundation
import UIKit

class MapFileParser {

    static let dimensionPixels = 1024
    static let maxBlocks = 32
    static let dimensionMm = 50 * 1024

    struct Chunk {
        var keyword: String
        var data: [UInt8]
    }

    enum Blocktype: Int {
        case chargerLocation = 1
        case image = 2
        case path = 3
        case gotoPath = 4
        case gotoPredictedPath = 5
        case currentlyCleanedZones = 6
        case gotoTarget = 7
        case robotPosition = 8
        case forbiddenZones = 9
        case virtualWalls = 10
        case currentlyCleanedBlocks = 11
        case forbiddenMopZones = 12
        case digest = 1024
    }


    fileprivate var mapData: MapData?
    fileprivate var mapImageData: MapData.MapImage?


    fileprivate var setPointLength: Int?
    fileprivate var setPointSize: Int?
    fileprivate var setAngle: Int?

    fileprivate var roboPath: [CGPoint] = []

    public func parse(_ data: Data) {

        guard data.getUtf8(position: 0) == "r" && data.getUtf8(position: 1) == "r" else {
            return
        }

        let mapData = parseBlock(data, offset: "0x14".hexaToDecimal)
        print("\(mapData)")
    }

    public func parseBlock(_ block: Data, offset: Int, mapData: MapData = MapData()) -> MapData {
        if block.count <= offset {
            return mapData
        }

        guard let blockTypeHeader = block.getBytes(position: "0x00".hexaToDecimal + offset, length: 2) else {
            print("no block header");
            return mapData
        }
        let headerLength = block.getInt16(position: "0x02".hexaToDecimal + offset)
        let blockLength = block.getInt32(position: "0x04".hexaToDecimal + offset)
        let blockType = Blocktype(rawValue: blockTypeHeader.getInt16(position: "0x00".hexaToDecimal))

        var tempMapData = mapData

        switch blockType {
        case .robotPosition:
            print(".robotPosition")
            tempMapData.robotPosition = parseRobotPositionBlock(block, blockLength: blockLength, offset: offset)
        case .chargerLocation:
            print(".charger")
            tempMapData.chargerLocation = parseChargerLocationBlock(block, offset: offset)
        case .image:
            print(".image")
            tempMapData.image = parseImageBlock(block, headerLength: headerLength, blockLength: blockLength, offset: offset)
        case .path:
            print(".path")
        case .gotoPath:
            print(".gotopath")
        case .gotoPredictedPath:
            print(".gotoPredictedPath")
            tempMapData.gotoPredictedPath = parseGoToPredictedPathBlock(block, blockLength: blockLength, offset: offset)
        case .gotoTarget:
            print(".gotoTarget")
        case .currentlyCleanedZones:
            print(".currentlyCleanedZones")
        case .forbiddenZones:
            print(".forbiddenZones")
        case .forbiddenMopZones:
            print(".forbiddenMopZones")
        case .virtualWalls:
            print(".virtualWalls")
        case .currentlyCleanedBlocks:
            print(".currentlyCleanedBlocks")
        case .digest:
            print(".digest")
        default:
            print("Error: Unknown blocktype")
            break
        }

        return parseBlock(block, offset: offset + headerLength + blockLength, mapData: tempMapData)
    }

    public func parseRobotPositionBlock(_ block: Data, blockLength: Int, offset: Int) -> MapData.RobotPosition {
        let x = block.getInt32(position: "0x08".hexaToDecimal + offset)
        let y = block.getInt32(position: "0x0C".hexaToDecimal + offset)
        let angle = blockLength >= 12 ? block.getInt32(position: "0x10".hexaToDecimal + offset) : nil
        return MapData.RobotPosition(x: x, y: y, angle: angle)
    }

    public func parseChargerLocationBlock(_ block: Data, offset: Int) -> MapData.ChargerLocation {
        let x = block.getInt32(position: "0x08".hexaToDecimal + offset)
        let y = block.getInt32(position: "0x0C".hexaToDecimal + offset)
        return MapData.ChargerLocation(x: x, y: y)
    }

    public func parseImageBlock(_ block: Data, headerLength: Int, blockLength: Int, offset: Int) -> MapData.MapImage {
        let segments = MapData.MapImage.Segments(count: block.getInt32(position: "0x08".hexaToDecimal),
                                                 center: [:],
                                                 borders: [],
                                                 neighbours: [:])

        let position = MapData.MapImage.Position(top: block.getInt32(position: "0x08".hexaToDecimal),
                                                 left: block.getInt32(position: "0x0C".hexaToDecimal))

        let dimensions = MapData.MapImage.Dimensions(height: block.getInt32(position: "0x10".hexaToDecimal),
                                                     width: block.getInt32(position: "0x14".hexaToDecimal))

        let box = MapData.MapImage.Box(minX: .max, minY: .max, maxX: .max, maxY: .max)

        var image = MapData.MapImage(segments: segments, position: position, dimensions: dimensions, box: box, pixels: [:])

        if dimensions.width > 0 && dimensions.height > 0 {
            image = parseImagePixelBlock(block, blockLength: blockLength, image: image, offset: offset)
        } else {
            image.box = MapData.MapImage.Box(minX: 0, minY: 0, maxX: 100, maxY: 100)
        }
        return image
    }

    public func parseImagePixelBlock(_ block: Data, blockLength: Int, image: MapData.MapImage, offset: Int) -> MapData.MapImage {
        var x: Int
        var y: Int
        var v: Int
        var s: Int
        var k: Int
        var m: Bool
        var n: Bool

        var tempImage = image

        // tempImage.position.top = MapFileParser.dimensionPixels - tempImage.position.top - tempImage.dimensions.height

        for index in 0..<blockLength {
            x = (index % tempImage.dimensions.width) + tempImage.position.left
            y = (tempImage.dimensions.height - 1 - (index/tempImage.dimensions.width)) + tempImage.position.top
            k = y * MapFileParser.dimensionPixels + x

            let blockType = block.getInt8(position: "0x00".hexaToDecimal + index)

            switch blockType {
            case 0:
                v = -1 // empty
                break
            case 1:
                v = 0 // obstacle
                break
            default:
                v = 1 // floor
                s = (blockType)
                if s != 0 {
                    v = (s << 1) //segment
                    // centers
                    if tempImage.segments.center[s] == nil {
                        tempImage.segments.center[s] = MapData.MapImage.Center(x: 0, y: 0, count: 0)
                    }
                    tempImage.segments.center[s]?.x += x
                    tempImage.segments.center[s]?.y += y
                    tempImage.segments.center[s]?.count += 1

                    // borders
                    n = false
                    m = false

                    if let pixels = tempImage.pixels[k-1], pixels > 1 && pixels != v {
                        n = true
                        tempImage.segments.neighbours[s * MapFileParser.maxBlocks + pixels/2] = true
                        tempImage.segments.neighbours[pixels/2 * MapFileParser.maxBlocks + s] = true
                    }
                    if let pixels = tempImage.pixels[k + MapFileParser.dimensionPixels], pixels > 1 && pixels != v {
                        m = true
                        tempImage.segments.neighbours[s * MapFileParser.maxBlocks + (pixels/2)] = true
                        tempImage.segments.neighbours[(pixels/2) * MapFileParser.maxBlocks + s] = true
                    }
                    if (n || m) {
                        tempImage.segments.borders.append(k)
                    }
                }
                break
            }
            if tempImage.box.minX > x {
                tempImage.box.minX = x
            }
            if tempImage.box.maxX < x {
                tempImage.box.maxX = x
            }
            if tempImage.box.minY > y {
                tempImage.box.minY = y
            }
            if tempImage.box.maxY < y {
                tempImage.box.maxY = y
            }
            tempImage.pixels[k] = v
        }
        return tempImage
    }

    public func parseGoToPredictedPathBlock(_ block: Data, blockLength: Int, offset: Int) -> MapData.Path {
        var points: [Int] = []
        let currentAngle = block.getInt32(position: "0x10".hexaToDecimal + offset)

        for index in 0..<blockLength {
            points.append(block.getInt16(position: "0x14".hexaToDecimal) + offset + index)
            points.append(block.getInt16(position: "0x14".hexaToDecimal) + offset + index + 2)
        }
        return MapData.Path(currentAngle: currentAngle, points: points)
    }
}
