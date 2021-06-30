//
//  MapDataParser.swift
//  Roborock
//
//  Created by Hack, Thomas on 28.06.21.
//

import UIKit
import Gzip

class MapDataParser {
    
    enum MapDataError: Error {
        case gzipError
        case parsingError
        case unexpected
    }
    
    static let dimensionPixels: Int = 1024
    static let maxBlocks = 32
    static let dimensionMm = 50.0 * 1024.0
    
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
    
    fileprivate var data: Data?
    fileprivate var mapData: MapData = MapData()
    
    
    /// Unzip and parse data from Websocket
    /// - Parameter data: Gzipped binary data array
    /// - Returns: Image with map, robot, paths, etc.
    public func parse(_ data: Data) -> MapData {
        if data.isGzipped {
            do {
                self.data = try data.gunzipped()
                self.mapData = parseBlocks()
            } catch {
                print(String(describing: error))
            }
        }
        return self.mapData
    }
    
    
    /// Parse response data from Websocket
    /// - Parameter data: Binary array
    /// - Returns: Image with map, robot, paths, etc.
    public func parseBlocks() -> MapData {
        // Check for valid RR map format
        guard let data = self.data, data.getUtf8(position: 0) == "r"
                && data.getUtf8(position: 1) == "r" else { return self.mapData }
        
        // Parse map data
        let mapData = parseBlock(data, offset: 0x14)
        
        // Generate map image
        guard let mapImageData: MapData.ImageData = mapData.imageData else { return self.mapData }
        
        // Draw map
        self.mapData.image =  drawMapImage(pixels: mapImageData.pixels, width: mapImageData.dimensions.width, height: mapImageData.dimensions.height)
        
        // Draw robot on map
        if let robot = mapData.robotPosition {
            self.mapData.image = drawRobot(image: self.mapData.image, robot: robot)
        }
        
        // Draw vaccum path on map
        if let paths = mapData.gotoPath {
            self.mapData.image = drawMapPaths(image: self.mapData.image, path: paths)
        }
        
        return self.mapData
    }
    
    /// Parse binary data block
    /// - Parameters:
    ///   - block: Data binary array
    ///   - offset: Current offset, increments per block
    ///   - mapData: Map data result object
    /// - Returns: Parsed Map data
    fileprivate func parseBlock(_ block: Data, offset: Int, mapData: MapData = MapData()) -> MapData {
        if block.count <= offset {
            return mapData
        }
        
        guard let _ = block.getBytes(position: 0x00 + offset, length: 2) else {
            print("no block header");
            return mapData
        }
        let headerLength = block.getInt16(position: 0x02 + offset)
        let blockLength = block.getInt32(position: 0x04 + offset)
        let blockType = Blocktype(rawValue: block.getInt16(position: 0x00 + offset))
        
        var tempMapData = mapData
        
        tempMapData.meta = parseMetaBlock(block)
        
        switch blockType {
        case .robotPosition:
            tempMapData.robotPosition = parseRobotPositionBlock(block, blockLength: blockLength, offset: offset)
        case .chargerLocation:
            tempMapData.chargerLocation = parseChargerLocationBlock(block, offset: offset)
        case .image:
            tempMapData.imageData = parseImageBlock(block, headerLength: headerLength, blockLength: blockLength, offset: offset)
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
    
    
    /// Parse first meta block in binary array
    /// - Parameter block: Data block that contains block header and data
    /// - Returns: MapData.Meta Block meta information
    fileprivate func parseMetaBlock(_ block: Data) -> MapData.Meta {
        let headerLength = block.getInt16(position: 0x02)
        let dataLength = block.getInt32(position: 0x04)
        let majorVersion = block.getInt16(position: 0x08)
        let minorVersion = block.getInt16(position: 0x0A)
        let mapIndex = block.getInt32(position: 0x0c)
        let mapSequence = block.getInt32(position: 0x10)
        let version = MapData.Meta.Version(major: majorVersion, minor: minorVersion)
        return MapData.Meta(headerLength: headerLength, dataLength: dataLength, version: version, mapIndex: mapIndex, mapSequence: mapSequence)
    }
    
    
    /// Parse robot position block
    /// - Parameters:
    ///   - block: Data block that contains block header and data
    ///   - blockLength: Int length of current data block (not including header)
    ///   - offset: Int current offset, increments per block
    /// - Returns: MapData.Robotposition coordinates and angle of robot
    fileprivate func parseRobotPositionBlock(_ block: Data, blockLength: Int, offset: Int) -> MapData.RobotPosition {
        let x = block.getInt32(position: 0x08 + offset)
        let y = block.getInt32(position: 0x0C + offset)
        let angle = blockLength >= 12 ? block.getInt32(position: 0x10 + offset) : nil
        return MapData.RobotPosition(position: MapData.Point(x: x, y: y), angle: angle)
    }
    
    
    /// Parse charger location block
    /// - Parameters:
    ///   - block: Data block that contains block header and data
    ///   - offset: Int current offset, increments per block
    /// - Returns: Charger coordinates
    fileprivate func parseChargerLocationBlock(_ block: Data, offset: Int) -> MapData.Point {
        let x = block.getInt32(position: 0x08 + offset)
        let y = block.getInt32(position: 0x0C + offset)
        return MapData.Point(x: x, y: y)
    }
    
    
    /// Parse vacuum paths
    /// - Parameters:
    ///   - block: Data block that contains block header and data
    ///   - blockLength: Length of current data block (not including header)
    ///   - offset: Current offset, increments per block
    /// - Returns: Current angle and array of driven paths from vacuum
    fileprivate func parsePathBlock(_ block: Data, blockLength: Int, offset: Int) -> MapData.Path {
        var points: [MapData.Point] = []
        let currentAngle = block.getInt32(position: 0x10 + offset)
        
        for index in 0..<blockLength {
            let x = block.getInt16(position: 0x14) + offset + index
            let y = block.getInt16(position: 0x16) + offset + index
            points.append(MapData.Point(x: x, y: y))
        }
        return MapData.Path(currentAngle: currentAngle, points: points)
    }
    
    
    /// Parse image block with all information including segments, dimensions, positions and pixel information
    /// - Parameters:
    ///   - block: Data block that contains block header and data
    ///   - headerLength: Length of header of current block as this might have differences between versions
    ///   - blockLength: Length of current data block (not including header)
    ///   - offset: Current offset, increments per block
    /// - Returns: Parsed image data from binary array with segments, dimensions, pixel array, etc.
    fileprivate func parseImageBlock(_ block: Data, headerLength: Int, blockLength: Int, offset: Int) -> MapData.ImageData {
        var g3offset = 0
        if headerLength > 24 {
            g3offset = 4
        }
        let segments = MapData.ImageData.Segments(count: g3offset > 0 ? block.getInt32(position: 0x08 + offset) : 0,
                                                  center: [:],
                                                  borders: [],
                                                  neighbours: [:])
        
        let position = MapData.Position(top: block.getInt32(position: 0x08 + g3offset + offset),
                                        left: block.getInt32(position: 0x0c + g3offset + offset))
        
        let dimensions = MapData.Size(width: block.getInt32(position: 0x14 + g3offset + offset),
                                      height: block.getInt32(position: 0x10 + g3offset + offset))
        
        let box = MapData.ImageData.Box(minX: .infinity, minY: .infinity, maxX: .infinity, maxY: .infinity)
        
        var image = MapData.ImageData(segments: segments, position: position, dimensions: dimensions, box: box, pixels: [])
        
        if dimensions.width > 0 && dimensions.height > 0 {
            image = parseImagePixelBlock(block, blockLength: blockLength, image: image, offset: offset, g3offset: g3offset)
        } else {
            image.box = MapData.ImageData.Box(minX: 0, minY: 0, maxX: 100, maxY: 100)
        }
        return image
    }
    
    
    /// Parse pixel array block from binary data of map image
    /// - Parameters:
    ///   - block: Data block that contains block header and data
    ///   - blockLength: Length of current data block (not including header)
    ///   - image: Parsed image data from binary array with segments, dimensions, pixel array, etc.
    ///   - offset: Current offset, increments per block
    ///   - g3offset: Specific offset for generation 3+ vacuums and map version >= 1.1 as block header is 4 bytes longer
    /// - Returns: Parsed image data from binary array with pixel array (width*height) in rgba
    fileprivate func parseImagePixelBlock(_ block: Data, blockLength: Int, image: MapData.ImageData, offset: Int, g3offset: Int) -> MapData.ImageData {
        var tempImage = image
        var mapImageData = MapData.ImageData.Data(floor: [],
                                                  obstacleWeak: [],
                                                  obstacleStrong: [])
        
        let freeColor = UIColor(red: 57/255, green: 127/255, blue: 224/255, alpha: 1)
        let floorColor = UIColor(red: 86/255, green: 175/255, blue: 252/255, alpha: 1)
        let obstacleColor = UIColor(red: 161/255, green: 219/255, blue: 255/255, alpha: 1)
        
        tempImage.position.top = MapDataParser.dimensionPixels - tempImage.position.top - tempImage.dimensions.height
        
        for index in 0 ..< blockLength {
            let x = (index % image.dimensions.width) + image.position.left
            let y = image.dimensions.height - 1 - (index / image.dimensions.width) + image.position.top
            
            let type = block.getInt8(position: 0x18 + g3offset + offset + index)
            
            switch type & 0x07 {
            case 0: // Free
                tempImage.pixels.append(freeColor.toPixel)
            case 1: // Obstacle
                tempImage.pixels.append(obstacleColor.toPixel)
                mapImageData.obstacleStrong.append(MapData.Point(x: x, y: y))
            default: // Segment or floor
                let segmentId = (type & 248) >> 3
                if segmentId != 0 {
                    tempImage.pixels.append(floorColor.toPixel)
                    mapImageData.floor.append(MapData.Point(x: x, y: y))
                    break
                }
                tempImage.pixels.append(floorColor.toPixel)
                mapImageData.floor.append(MapData.Point(x: x, y: y))
            }
        }
        
        tempImage.data = mapImageData
        return tempImage
    }
    
    
    /// Draw actual map image from pixel array
    /// - Parameters:
    ///   - pixels: Pixel array containing rgba information for every pixel
    ///   - width: Width of map image from vacuum
    ///   - height: Height of map image from vacuum
    /// - Returns: Image with floor, walls, obstacles and segments
    fileprivate func drawMapImage(pixels: [MapData.Pixel], width: Int, height: Int) -> UIImage? {
        guard width > 0 && height > 0 else { return nil }
        guard pixels.count == width * height else { return nil }
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        
        var data = pixels // Copy to mutable []
        guard let providerRef = CGDataProvider(data: NSData(bytes: &data, length: data.count * MemoryLayout<MapData.Pixel>.size) ) else { return nil }
        
        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: width * MemoryLayout<MapData.Pixel>.size,
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    
    /// Draw vacuum paths onto map image
    /// - Parameters:
    ///   - image: Source image to draw on
    ///   - path: Path object containing angle and point array
    /// - Returns: Map image including paths
    fileprivate func drawMapPaths(image: UIImage?, path: MapData.Path) -> UIImage? {
        guard let image = image else { return nil }
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: CGPoint.zero)
        
        let context = UIGraphicsGetCurrentContext()!
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.red.cgColor)
        
        for (index, point) in path.points.enumerated() {
            if index == 0 {
                context.move(to: CGPoint(x: point.x, y: point.y))
            } else {
                // context.addLine(to: CGPoint(x: point.x / (50 * image.size.width), y: point.y / (50 * image.size.height)))
                context.strokePath()
            }
        }
        let tempImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tempImage
    }
    
    
    /// Draw vacuum robot onto map image
    /// - Parameters:
    ///   - image: Source image to draw on
    ///   - robot: Robot object containing angle and coordinates
    /// - Returns: Map image including robot
    fileprivate func drawRobot(image: UIImage?, robot: MapData.RobotPosition) -> UIImage? {
        guard let image = image else { return nil }
        
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: CGPoint.zero)
        
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(UIColor.green.cgColor)
        context.setLineWidth(5.0)
        context.addEllipse(in: CGRect(x: 320, y: 275, width: 24, height: 24))
        context.drawPath(using: .stroke) // or .fillStroke if need filling
        
        let tempImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tempImage
    }
}
