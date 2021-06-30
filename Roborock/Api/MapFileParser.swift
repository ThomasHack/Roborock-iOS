//
//  RRFileParser.swift
//  Roborock
//
//  Created by Hack, Thomas on 28.06.21.
//

import UIKit

struct PixelData {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8 = 255
}

class MapFileParser {

    static let dimensionPixels = 1024.0
    static let maxBlocks = 32
    static let dimensionMm = 50.0 * 1024.0

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
    fileprivate var mapImageData: MapData.ImageData?


    fileprivate var setPointLength: Int?
    fileprivate var setPointSize: Int?
    fileprivate var setAngle: Int?

    fileprivate var roboPath: [CGPoint] = []

    public func parse(_ data: Data) -> UIImage? {
        // Check for valid RR map format
        guard data.getUtf8(position: 0) == "r" && data.getUtf8(position: 1) == "r" else { return nil }

        // Parse map data
        let mapData = parseBlock(data, offset: "0x14".hexaToDecimal)

        // Generate map image
        guard let mapImageData: MapData.ImageData = mapData.image else { return nil }
        let mapImage = drawMapImage(pixels: mapImageData.pixels, width: mapImageData.dimensions.width, height: mapImageData.dimensions.height)

        if let mapImage = mapImage,
            let paths = mapData.gotoPath,
            let pathImage = drawMapPaths(image: mapImage, path: paths) {
            return pathImage
        }
        return mapImage
    }

    /**
     * Parse map data blocks
     * @param block: Data - Binary data
     * @param offset: Int - Current offset
     * @param mapData: MapData - Current map data object
     */
    fileprivate func parseBlock(_ block: Data, offset: Int, mapData: MapData = MapData()) -> MapData {
        if block.count <= offset {
            return mapData
        }

        guard let _ = block.getBytes(position: "0x00".hexaToDecimal + offset, length: 2) else {
            print("no block header");
            return mapData
        }
        let headerLength = block.getInt16(position: "0x02".hexaToDecimal + offset)
        let blockLength = block.getInt32(position: "0x04".hexaToDecimal + offset)
        let blockType = Blocktype(rawValue: block.getInt16(position: "0x00".hexaToDecimal + offset))

        var tempMapData = mapData

        tempMapData.meta = parseMetaBlock(block)

        switch blockType {
        case .robotPosition:
            tempMapData.robotPosition = parseRobotPositionBlock(block, blockLength: blockLength, offset: offset)
        case .chargerLocation:
            tempMapData.chargerLocation = parseChargerLocationBlock(block, offset: offset)
        case .image:
            tempMapData.image = parseImageBlock(block, headerLength: headerLength, blockLength: blockLength, offset: offset)
        case .path:
            tempMapData.vacuumPath = parsePathBlock(block, blockLength: blockLength, offset: offset)
        case .gotoPath:
            tempMapData.gotoPath = parsePathBlock(block, blockLength: blockLength, offset: offset)
        case .gotoPredictedPath:
            tempMapData.gotoPredictedPath = parsePathBlock(block, blockLength: blockLength, offset: offset)
        case .gotoTarget, .currentlyCleanedZones, .currentlyCleanedBlocks, .forbiddenZones, .forbiddenMopZones, .virtualWalls:
            break
        case .digest:
            break
        default:
            print("Error: Unknown blocktype")
            break
        }
        return parseBlock(block, offset: offset + headerLength + blockLength, mapData: tempMapData)
    }

    fileprivate func parseMetaBlock(_ block: Data) -> MapData.Meta {
        let headerLength = block.getInt16(position: "0x02".hexaToDecimal)
        let dataLength = block.getInt32(position: "0x04".hexaToDecimal)
        let majorVersion = block.getInt16(position: "0x08".hexaToDecimal)
        let minorVersion = block.getInt16(position: "0x0A".hexaToDecimal)
        let mapIndex = block.getInt32(position: "0x0c".hexaToDecimal)
        let mapSequence = block.getInt32(position: "0x10".hexaToDecimal)
        let version = MapData.Meta.Version(major: majorVersion, minor: minorVersion)
        return MapData.Meta(headerLength: headerLength, dataLength: dataLength, version: version, mapIndex: mapIndex, mapSequence: mapSequence)
    }

    fileprivate func parseRobotPositionBlock(_ block: Data, blockLength: Int, offset: Int) -> MapData.RobotPosition {
        let x = block.getInt32(position: "0x08".hexaToDecimal + offset)
        let y = block.getInt32(position: "0x0C".hexaToDecimal + offset)
        let angle = blockLength >= 12 ? block.getInt32(position: "0x10".hexaToDecimal + offset) : nil
        return MapData.RobotPosition(position: CGPoint(x: x, y: y), angle: angle)
    }

    fileprivate func parseChargerLocationBlock(_ block: Data, offset: Int) -> CGPoint {
        let x = block.getInt32(position: "0x08".hexaToDecimal + offset)
        let y = block.getInt32(position: "0x0C".hexaToDecimal + offset)
        return CGPoint(x: x, y: y)
    }

    fileprivate func parsePathBlock(_ block: Data, blockLength: Int, offset: Int) -> MapData.Path {
        var points: [CGPoint] = []
        let currentAngle = block.getInt32(position: "0x10".hexaToDecimal + offset)

        for index in 0..<blockLength {
            let x = Double(block.getInt16(position: "0x14".hexaToDecimal) + offset + index)
            let y = Double(block.getInt16(position: "0x16".hexaToDecimal) + offset + index)
            points.append(CGPoint(x: x, y: y))
        }
        return MapData.Path(currentAngle: currentAngle, points: points)
    }

    fileprivate func parseImageBlock(_ block: Data, headerLength: Int, blockLength: Int, offset: Int) -> MapData.ImageData {
        var g3offset = 0
        if headerLength > 24 {
            g3offset = 4
        }
        let segments = MapData.ImageData.Segments(count: g3offset > 0 ? block.getInt32(position: "0x08".hexaToDecimal + offset) : 0,
                                              center: [:],
                                              borders: [],
                                              neighbours: [:])

        let position = MapData.ImageData.Position(top: block.getInt32(position: "0x08".hexaToDecimal + g3offset + offset),
                                              left: block.getInt32(position: "0x0c".hexaToDecimal + g3offset + offset))

        let dimensions = MapData.ImageData.Dimensions(height: block.getInt32(position: "0x10".hexaToDecimal + g3offset + offset),
                                                  width: block.getInt32(position: "0x14".hexaToDecimal + g3offset + offset))

        let box = MapData.ImageData.Box(minX: .infinity, minY: .infinity, maxX: .infinity, maxY: .infinity)

        var image = MapData.ImageData(segments: segments, position: position, dimensions: dimensions, box: box, pixels: [])

        if dimensions.width > 0 && dimensions.height > 0 {
            image = parseImagePixelBlock(block, blockLength: blockLength, image: image, offset: offset, g3offset: g3offset)
        } else {
            image.box = MapData.ImageData.Box(minX: 0, minY: 0, maxX: 100, maxY: 100)
        }
        return image
    }

    fileprivate func parseImagePixelBlock(_ block: Data, blockLength: Int, image: MapData.ImageData, offset: Int, g3offset: Int) -> MapData.ImageData {
        var tempImage = image
        var mapImageData = MapData.ImageData.Data(floor: [], obstacleWeak: [], obstacleStrong: [])

        let freeColor = UIColor(red: 57/255, green: 127/255, blue: 224/255, alpha: 1)
        let floorColor = UIColor(red: 86/255, green: 175/255, blue: 252/255, alpha: 1)
        let obstacleColor = UIColor(red: 161/255, green: 219/255, blue: 255/255, alpha: 1)

        tempImage.position.top = Int(MapFileParser.dimensionPixels) - tempImage.position.top - tempImage.dimensions.height

        for index in 0 ..< blockLength {
            let x = Double((index % image.dimensions.width)) + Double(image.position.left)
            let y = Double((image.dimensions.height - 1 - (index / image.dimensions.width))) + Double(image.position.top)

            let type = block.getInt8(position: "0x18".hexaToDecimal + g3offset + offset + index)

            switch type & 0x07 {
            case 0: // Free
                tempImage.pixels.append(freeColor.toPixelData)
            case 1: // Obstacle
                tempImage.pixels.append(obstacleColor.toPixelData)
                mapImageData.obstacleStrong.append(CGPoint(x: x, y: y))
            default: // Segment or floor
                let segmentId = (type & 248) >> 3
                if segmentId != 0 {
                    tempImage.pixels.append(floorColor.toPixelData)
                    mapImageData.floor.append(CGPoint(x: x, y: y))
                    break
                }
                tempImage.pixels.append(floorColor.toPixelData)
                mapImageData.floor.append(CGPoint(x: x, y: y))
            }
        }

        tempImage.data = mapImageData
        return tempImage
    }

    fileprivate func drawMapImage(pixels: [PixelData], width: Int, height: Int) -> UIImage? {
        guard width > 0 && height > 0 else { return nil }
        guard pixels.count == width * height else { return nil }

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let bitsPerComponent = 8
        let bitsPerPixel = 32

        var data = pixels // Copy to mutable []
        guard let providerRef = CGDataProvider(data: NSData(bytes: &data, length: data.count * MemoryLayout<PixelData>.size) ) else { return nil }

        guard let cgim = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: width * MemoryLayout<PixelData>.size,
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else { return nil }

        return UIImage(cgImage: cgim)
    }

    fileprivate func drawMapPaths(image: UIImage, path: MapData.Path) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: CGPoint.zero)

        let context = UIGraphicsGetCurrentContext()!
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.red.cgColor)

        for (index, point) in path.points.enumerated() {
            if index == 0 {
                context.move(to: CGPoint(x: point.x, y: point.y))
            } else {
                context.addLine(to: CGPoint(x: point.x/50*image.size.width, y: point.y/50*image.size.height))
                context.strokePath()
            }
        }
        let tempImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return tempImage
    }
}
