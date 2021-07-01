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

    static let dimensionPixels = 1024
    static let maxBlocks = 32
    static let dimensionMm = 50.0 * 1024.0
    
    fileprivate var data: Data?
    fileprivate var mapData: MapData = MapData()
    
    
    /// Unzip and parse data from Websocket
    /// - Parameter data: Gzipped binary data array
    /// - Returns: Image with map, robot, paths, etc.
    public func parse(_ data: Data) -> MapData {
        if data.isGzipped {
            do {
                self.data = try data.gunzipped()
                parseBlocks()
            } catch {
                print(String(describing: error))
            }
        }
        return self.mapData
    }
    
    
    /// Parse response data from Websocket
    /// - Parameter data: Binary array
    /// - Returns: Image with map, robot, paths, etc.
    fileprivate func parseBlocks() {
        // Check for valid RR map format
        guard let data = self.data, data[0] == 0x72 && data[1] == 0x72 else { return }
        
        // Parse map data
        parseBlock(data, offset: 0x14)
        
        // Generate map image
        guard let mapImageData: MapData.ImageData = mapData.imageData else { return }

        // Draw map
        self.mapData.image = drawMapImage(pixels: mapImageData.pixels, size: mapImageData.dimensions)
        
        // Draw charger on map
        if let charger = mapData.chargerLocation {
            self.mapData.image = drawCharger(image: self.mapData.image, charger: charger, size: mapImageData.dimensions)
        }
        
        // Draw vaccum path on map
        if let paths = mapData.vacuumPath {
            self.mapData.image = drawMapPaths(image: self.mapData.image, path: paths, size: mapImageData.dimensions, position: mapImageData.position)
        }
        
        // Draw vaccum path on map
        if let paths = mapData.gotoPath {
            self.mapData.image = drawMapPaths(image: self.mapData.image, path: paths, size: mapImageData.dimensions, position: mapImageData.position)
        }
        
        // Draw robot on map
        if let robot = mapData.robotPosition {
            self.mapData.image = drawRobot(image: self.mapData.image, robot: robot, size: mapImageData.dimensions)
        }
        
        if let cgImage = self.mapData.image?.cgImage {
            self.mapData.image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .downMirrored)
        }
    }
    
    /// Parse binary data block
    /// - Parameters:
    ///   - block: Data binary array
    ///   - offset: Current offset, increments per block
    ///   - mapData: Map data result object
    /// - Returns: Parsed Map data
    fileprivate func parseBlock(_ data: Data, offset: Int, mapData: MapData = MapData()) {
        if data.count <= offset {
            return
        }

        guard let blockType = MapData.Blocktype(rawValue: data.getInt16(position: 0x00 + offset)) else {
            print("no block header")
            return
        }

        let headerLength = data.getInt16(position: 0x02 + offset)
        let blockLength = data.getInt32(position: 0x04 + offset)

        self.mapData.meta = parseMetaBlock(data)
        self.mapData.blocks[blockType] = data.getBytes(position: 0x00 + offset, length: headerLength + blockLength)
        
        switch blockType {
        case .robotPosition:
            self.mapData.robotPosition = parseRobotPositionBlock(data, blockLength: blockLength, offset: offset)
        case .chargerLocation:
            self.mapData.chargerLocation = parseChargerLocationBlock(data, offset: offset)
        case .image:
            self.mapData.imageData = parseImageBlock(data, headerLength: headerLength, blockLength: blockLength, offset: offset)
        case .path:
            self.mapData.vacuumPath = parsePathBlock(data, blockLength: blockLength, offset: offset)
        case .gotoPath:
            self.mapData.gotoPath = parsePathBlock(data, blockLength: blockLength, offset: offset)
        case .gotoPredictedPath:
            self.mapData.gotoPredictedPath = parsePathBlock(data, blockLength: blockLength, offset: offset)
        case .gotoTarget, .currentlyCleanedZones, .currentlyCleanedBlocks, .forbiddenZones, .forbiddenMopZones, .virtualWalls:
            break
        case .digest:
            break
        }
        return parseBlock(data, offset: offset + headerLength + blockLength, mapData: self.mapData)
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
        let angle = block.getInt32(position: 0x10 + offset)
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
        
        for index in stride(from: 0, through: blockLength, by: 4) {
            let x = block.getInt16(position: 0x14 + offset + index)
            let y = block.getInt16(position: 0x14 + offset + index + 2)
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
        
        // tempImage.position.top = MapDataParser.dimensionPixels - tempImage.position.top - tempImage.dimensions.height
        
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
    fileprivate func drawMapImage(pixels: [MapData.Pixel], size: MapData.Size) -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var data = pixels
        let context = data.withUnsafeMutableBytes { pixelsPointer in
            return CGContext(data: pixelsPointer.baseAddress,
                        width: size.width,
                        height: size.height,
                        bitsPerComponent: 8,
                        bytesPerRow: size.width * MemoryLayout<MapData.Pixel>.size,
                        space: colorSpace,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        }

        guard let image = context?.makeImage() else { return nil }
        return UIImage(cgImage: image)

    }
    
    fileprivate func convertToMapCoordinate(_ coordinate: Int, offset: Int) -> Int {
        return Int(Double(coordinate) / 50.0 - Double(offset))
    }
    
    /// Draw vacuum paths onto map image
    /// - Parameters:
    ///   - image: Source image to draw on
    ///   - path: Path object containing angle and point array
    /// - Returns: Map image including paths
    fileprivate func drawMapPaths(image: UIImage?, path: MapData.Path, size: MapData.Size, position: MapData.Position) -> UIImage? {
        guard let image = image else { return nil }
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: CGPoint.zero)
        
        let context = UIGraphicsGetCurrentContext()!
        context.setLineWidth(1.0)
        context.setStrokeColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.8).cgColor)
                
        for index in 0..<path.points.count - 1 {
            if index != 0 {
                let point = path.points[index]
                let x = convertToMapCoordinate(point.x, offset: position.left)
                let y = convertToMapCoordinate(point.y, offset: position.top)

                let previousPoint = path.points[index - 1]
                let prevX = convertToMapCoordinate(previousPoint.x, offset: position.left)
                let prevY = convertToMapCoordinate(previousPoint.y, offset: position.top)

                context.move(to: CGPoint(x: prevX, y: prevY))
                context.addLine(to: CGPoint(x: x, y: y))
                context.strokePath()
            } else {
                let point = path.points[index]
                let x = convertToMapCoordinate(point.x, offset: position.left)
                let y = convertToMapCoordinate(point.y, offset: position.top)
                context.move(to: CGPoint(x: x, y: y))
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
    fileprivate func drawRobot(image: UIImage?, robot: MapData.RobotPosition, size: MapData.Size) -> UIImage? {
        guard let image = image, let imageData = self.mapData.imageData else { return nil }

        let x = (robot.position.x/50) - imageData.position.left;
        let y = (robot.position.y/50) - imageData.position.top
        
        guard let angle = robot.angle,
              let robotImage = UIImage(named: "robot")?.rotate(radians: Float(angle + 90)) else { return nil }
        
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        robotImage.draw(in: CGRect(origin: CGPoint(x: x - 10, y: y - 10), size: CGSize(width: 20, height: 20)))
        
        let tempImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tempImage
    }
    
    /// Draw vacuum charger onto map image
    /// - Parameters:
    ///   - image: Source image to draw on
    ///   - charger: Charger coordinates
    /// - Returns: Map image including robot
    fileprivate func drawCharger(image: UIImage?, charger: MapData.Point, size: MapData.Size) -> UIImage? {
        guard let image = image, let imageData = self.mapData.imageData else { return nil }

        let x = (charger.x/50) - imageData.position.left;
        let y = (charger.y/50) - imageData.position.top
        
        let chargerImage = UIImage(named: "charger")!
        
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        chargerImage.draw(in: CGRect(origin: CGPoint(x: x - 10, y: y - 10), size: CGSize(width: 20, height: 20)))
        
        let tempImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tempImage
    }
}
