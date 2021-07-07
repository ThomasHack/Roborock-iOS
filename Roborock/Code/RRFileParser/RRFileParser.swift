//
//  MapDataParser.swift
//  Roborock
//
//  Created by Hack, Thomas on 28.06.21.
//  https://github.com/marcelrv/XiaomiRobotVacuumProtocol/blob/master/RRMapFile/RRFileFormat.md

import UIKit
import Combine
import Gzip
import SwiftUI

enum ParsingError: Error {
    case gzipError
    case parsingError
    case imageGeneration
    case unexpected
}

enum ImageGenerationError: Error {
    case mapImageError
    case pathImageError
    case forbiddenZonesImageError
    case robotImageError
    case chargerImageError
}

class RRFileParser {
    private var data: Data?
    private var mapData: MapData = MapData()
    
    public var segments: [Int] = []

    private var imagePosition: MapData.Position {
        guard let position = mapData.imageData?.position else {
            return MapData.Position(top: 0, left: 0)
        }
        return position
    }

    private var imageSize: CGSize {
        guard let size = mapData.imageData?.dimensions else {
            return CGSize.zero
        }
        return CGSize(width: size.width, height: size.height)
    }

    private var retinaImageSize: CGSize {
        guard let size = mapData.imageData?.dimensions else {
            return CGSize.zero
        }
        return CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
    }

    private var scaleFactor: Int = 2

    // MARK: - Public methods

    /// Parse data from Websocket
    /// - Parameter data: Gzipped binary data array
    /// - Returns: Promise with MapData or MapDataError
    func parse(_ data: Data) -> AnyPublisher<MapData, ParsingError> {
        Future { promise in
            self.parseData(data)
            promise(.success(self.mapData))
        }
        .eraseToAnyPublisher()
    }


    /// Parse current data again to refresh images
    /// - Returns: Promise with MapData or MapDataError
    func refreshData() -> AnyPublisher<MapData, ParsingError> {
        Future { promise in
            self.parseBlocks()
            promise(.success(self.mapData))
        }
        .eraseToAnyPublisher()
    }


    /// Draw map image
    /// - Returns: Promise with Image or Error
    public func drawMapImage() -> AnyPublisher<UIImage, ImageGenerationError> {
        Future { promise in
            self.drawMap { result in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }

    /// Draw path image
    /// - Returns: Promise with Image or Error
    public func drawPathsImage() -> AnyPublisher<UIImage, ImageGenerationError> {
        Future { promise in
            self.drawMapPaths { result in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }

    /// Draw forbidden zones image
    /// - Returns: Promise with Image or Error
    public func drawForbiddenZonesImage() -> AnyPublisher<UIImage, ImageGenerationError> {
        Future { promise in
            self.drawForbiddenZonesImage { result in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }

    /// Draw robot image
    /// - Returns: Promise with Image or Error
    public func drawRobotImage() -> AnyPublisher<UIImage, ImageGenerationError> {
        Future { promise in
            self.drawRobotImage() { result in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }

    /// Draw charger image
    /// - Returns: Promise with Image or Error
    public func drawChargerImage() -> AnyPublisher<UIImage, ImageGenerationError> {
        Future { promise in
            self.drawChargerImage() { result in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }

    /// Draw segment names image
    /// - Returns: Promise with Image or Error
    public func drawSegmentLabelsImage() -> AnyPublisher<UIImage, ImageGenerationError> {
        Future { promise in
            self.drawSegmentLabelsImage() { result in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Parsing
    
    /// Provides custom color for segment
    /// - Parameter segment: Segment object
    /// - Returns: Color
    private func colorForSegmentId(segment: SegmentType?) -> UIColor {
        switch segment {
        case .studio,. bath, .bedroom, .corridor, .kitchen, .livingroom, .toilet, .supply:
            return UIColor.floorColor
        default:
            return UIColor.floorColor
        }
    }

    /// Unzip and parse data from Websocket
    /// - Parameter data: Gzipped binary data array
    /// - Returns: Image with map, robot, paths, etc.
    private func parseData(_ data: Data) {
        if data.isGzipped {
            do {
                self.data = try data.gunzipped()
                parseBlocks()
            } catch {
                print(String(describing: error))
            }
        }
    }

    /// Parse response data from Websocket
    /// - Parameter data: Binary array
    /// - Returns: Image with map, robot, paths, etc.
    private func parseBlocks() {
        // Check for valid RR map format
        guard let data = self.data, data[0] == 0x72 && data[1] == 0x72 else { return }

        // Parse map data
        parseBlock(data, offset: 0x14)
    }

    /// Parse binary data block
    /// - Parameters:
    ///   - block: Data binary array
    ///   - offset: Current offset, increments per block
    ///   - mapData: Map data result object
    /// - Returns: Parsed Map data
    private func parseBlock(_ data: Data, offset: Int, mapData: MapData = MapData()) {
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
            self.mapData.imageData = parseMapBlocks(data, headerLength: headerLength, blockLength: blockLength, offset: offset)
        case .path:
            self.mapData.vacuumPath = parsePathBlock(data, blockLength: blockLength, offset: offset, type: .vacuum)
        case .gotoPath:
            self.mapData.gotoPath = parsePathBlock(data, blockLength: blockLength, offset: offset, type: .goto)
        case .gotoPredictedPath:
            self.mapData.gotoPredictedPath = parsePathBlock(data, blockLength: blockLength, offset: offset, type: .predicted)
        case .forbiddenZones:
            self.mapData.forbiddenZones = parseForbiddenZones(data, blockLength: blockLength, offset: offset)
        case .currentlyCleanedZones, .currentlyCleanedBlocks, .gotoTarget, .forbiddenMopZones, .virtualWalls:
            break
        case .digest:
            break
        }
        return parseBlock(data, offset: offset + headerLength + blockLength, mapData: self.mapData)
    }


    /// Parse first meta block in binary array
    /// - Parameter block: Data block that contains block header and data
    /// - Returns: MapData.Meta Block meta information
    private func parseMetaBlock(_ block: Data) -> MapData.Meta {
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
    private func parseRobotPositionBlock(_ block: Data, blockLength: Int, offset: Int) -> MapData.RobotPosition {
        let x = block.getInt32(position: 0x08 + offset)
        let y = block.getInt32(position: 0x0C + offset)
        let angle = block.getInt8(position: 0x10 + offset)
        return MapData.RobotPosition(position: MapData.Point(x: x, y: y), angle: angle)
    }


    /// Parse charger location block
    /// - Parameters:
    ///   - block: Data block that contains block header and data
    ///   - offset: Int current offset, increments per block
    /// - Returns: Charger coordinates
    private func parseChargerLocationBlock(_ block: Data, offset: Int) -> MapData.Point {
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
    private func parsePathBlock(_ block: Data, blockLength: Int, offset: Int, type: MapData.Path.PathType) -> MapData.Path {
        var points: [MapData.Point] = []
        let currentAngle = block.getInt32(position: 0x10 + offset)

        for index in stride(from: 0, through: blockLength, by: 4) {
            let x = block.getInt16(position: 0x14 + offset + index)
            let y = block.getInt16(position: 0x14 + offset + index + 2)
            points.append(MapData.Point(x: x, y: y))
        }
        return MapData.Path(currentAngle: currentAngle, points: points, type: type)
    }


    /// Parse forbidden zones
    /// - Parameters:
    ///   - block: Data block that contains block header and data
    ///   - blockLength: Length of current data block (not including header)
    ///   - offset: Current offset, increments per block
    /// - Returns: Array of forbidden zone coordinates with 4 points
    private func parseForbiddenZones(_ block: Data, blockLength: Int, offset: Int) -> MapData.ForbiddenZones {
        var zones: [[MapData.Point]] = []
        let count = block.getInt32(position: 0x08 + offset)

        for index in stride(from: 0, through: blockLength, by: 16) {
            let a = MapData.Point(x: block.getInt16(position: 0x0C + offset + index), y: block.getInt16(position: 0x0C + offset + index + 2))
            let b = MapData.Point(x: block.getInt16(position: 0x0C + offset + index + 4), y: block.getInt16(position: 0x0C + offset + index + 6))
            let c = MapData.Point(x: block.getInt16(position: 0x0C + offset + index + 8), y: block.getInt16(position: 0x0C + offset + index + 10))
            let d = MapData.Point(x: block.getInt16(position: 0x0C + offset + index + 12), y: block.getInt16(position: 0x0C + offset + index + 14))
            zones.append(contentsOf: [[a, b, c, d]])
        }
        return MapData.ForbiddenZones(count: count, zones: zones)
    }


    /// Parse image block with all information including segments, dimensions, positions and pixel information
    /// - Parameters:
    ///   - block: Data block that contains block header and data
    ///   - headerLength: Length of header of current block as this might have differences between versions
    ///   - blockLength: Length of current data block (not including header)
    ///   - offset: Current offset, increments per block
    /// - Returns: Parsed image data from binary array with segments, dimensions, pixel array, etc.
    private func parseMapBlocks(_ block: Data, headerLength: Int, blockLength: Int, offset: Int) -> MapData.ImageData {
        var g3offset = 0
        if headerLength > 24 {
            g3offset = 4
        }
        let segments = MapData.ImageData.Segments(count: g3offset > 0 ? block.getInt32(position: 0x08 + offset) : 0, center: [:])

        let position = MapData.Position(top: block.getInt32(position: 0x08 + g3offset + offset),
                                        left: block.getInt32(position: 0x0c + g3offset + offset))

        let dimensions = MapData.Size(width: block.getInt32(position: 0x14 + g3offset + offset),
                                      height: block.getInt32(position: 0x10 + g3offset + offset))

        var image = MapData.ImageData(segments: segments, position: position, dimensions: dimensions, pixels: [])

        if dimensions.width > 0 && dimensions.height > 0 {
            image = parseImageBlock(block, blockLength: blockLength, imageData: image, offset: offset, g3offset: g3offset)
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
    private func parseImageBlock(_ block: Data, blockLength: Int, imageData: MapData.ImageData, offset: Int, g3offset: Int) -> MapData.ImageData {
        var tempImageData = imageData

        let selectedColor = UIColor(red: 121/255, green: 196/255, blue: 189/255, alpha: 1)

        for index in 0 ..< blockLength {
            let x = (index % imageData.dimensions.width) + imageData.position.left
            let y = imageData.dimensions.height - 1 - (index / imageData.dimensions.width) + imageData.position.top

            let type = block.getInt8(position: 0x18 + g3offset + offset + index)

            switch type & 0x07 {
            case 0: // Free
                tempImageData.pixels.append(UIColor.freeColor.toPixel)
            case 1: // Obstacle
                tempImageData.pixels.append(UIColor.obstacleColor.toPixel)
            default: // Segment or floor
                let segmentId = (type & 248) >> 3
                if segmentId != 0 {
                    // Optional colors for each segment
                    var color = colorForSegmentId(segment: SegmentType(rawValue: segmentId))

                    // Color if segment is currently selected
                    if segments.contains(segmentId) {
                        color = selectedColor
                    }

                    if tempImageData.segments.center[segmentId] == nil {
                        tempImageData.segments.center[segmentId] = MapData.ImageData.Center(position: MapData.Point(x: 0, y: 0), count: 0)
                    }
                    tempImageData.segments.center[segmentId]?.position.x += x
                    tempImageData.segments.center[segmentId]?.position.y += y
                    tempImageData.segments.center[segmentId]?.count += 1

                    // Push segment divider pixel
                    let lastBlock = block.getInt8(position: 0x18 + g3offset + offset + index - 1)
                    if lastBlock > 1 && (lastBlock & 248) >> 3 != segmentId {
                        tempImageData.pixels.append(UIColor.clear.toPixel)
                        break
                    }

                    // Push segment divider pixel
                    let neighbourBlock = block.getInt8(position: 0x18 + g3offset + offset + index + imageData.dimensions.width)
                    if neighbourBlock > 1 && (neighbourBlock & 248) >> 3 != segmentId {
                        tempImageData.pixels.append(UIColor.clear.toPixel)
                        break
                    }
                    // Push segment pixel
                    tempImageData.pixels.append(color.toPixel)
                    break
                }
                // Push floor pixel
                tempImageData.pixels.append(UIColor.floorColor.toPixel)
            }
        }

        return tempImageData
    }

    // MARK: - Drawing
    
    /// Convert coordinate to map space
    /// - Parameters:
    ///   - coordinate: Axis coordinate
    ///   - offset: Map offset
    /// - Returns: Coordinate in map space
    private func convertToMapCoordinate(_ coordinate: Int, offset: Int) -> Int {
        return Int(Double(coordinate * scaleFactor) / 50.0 - Double(offset * scaleFactor))
    }

    /// Internal method to draw map image
    /// - Parameter completion: completion handler
    private func drawMap(completion: @escaping (Result<UIImage, ImageGenerationError>) -> ()) {
        guard let pixels = mapData.imageData?.pixels, let image = drawMap(pixels: pixels) else {
            completion(.failure(ImageGenerationError.mapImageError))
            return
        }
        completion(.success(image))
    }

    /// Internal method to draw vacuum, goto and predicted paths to a single image
    /// - Parameter completion: completion handler
    private func drawMapPaths(completion: @escaping (Result<UIImage, ImageGenerationError>) -> ()) {
        // Draw vaccum path on map
        var image = UIImage()

        if let paths = mapData.vacuumPath {
            guard let vaccumPathImage = drawMapPaths(path: paths, image: image) else {
                completion(.failure(ImageGenerationError.pathImageError))
                return
            }
            image = vaccumPathImage
        }

        // Draw vaccum path on map
        if let paths = mapData.gotoPredictedPath {
            guard let gotoPredictedPathImage = drawMapPaths(path: paths, image: image) else {
                completion(.failure(ImageGenerationError.pathImageError))
                return
            }
            image = gotoPredictedPathImage
        }

        // Draw vaccum path on map
        if let paths = mapData.gotoPath {
            guard let gotoPathImage = drawMapPaths(path: paths, image: image) else {
                completion(.failure(ImageGenerationError.pathImageError))
                return
            }
            image = gotoPathImage
        }

        completion(.success(image))
    }

    /// Internal method to draw forbidden zones image
    /// - Parameter completion: completion handler
    private func drawForbiddenZonesImage(completion: @escaping (Result<UIImage, ImageGenerationError>) -> ()) {
        guard let forbiddenZones = mapData.forbiddenZones, let image = drawForbiddenZones(zones: forbiddenZones) else {
            completion(.failure(ImageGenerationError.forbiddenZonesImageError))
            return
        }
        completion(.success(image))
    }

    /// Internal method to draw robot image
    /// - Parameter completion: completion handler
    private func drawRobotImage(completion: @escaping (Result<UIImage, ImageGenerationError>) -> ()) {
        guard let robotPosition = mapData.robotPosition, let image = drawRobot(robot: robotPosition) else {
            completion(.failure(ImageGenerationError.robotImageError))
            return
        }
        completion(.success(image))
    }

    /// Internal method to draw charger image
    /// - Parameter completion: completion handler
    private func drawChargerImage(completion: @escaping (Result<UIImage, ImageGenerationError>) -> ()) {
        guard let chargerLocation = mapData.chargerLocation, let image = drawCharger(charger: chargerLocation) else {
            completion(.failure(ImageGenerationError.chargerImageError))
            return
        }
        completion(.success(image))
    }


    /// Internal method to draw segment labels
    /// - Parameter completion: completion handler
    private func drawSegmentLabelsImage(completion: @escaping (Result<UIImage, ImageGenerationError>) -> ()) {
        guard let segments = mapData.imageData?.segments, let image = drawSegmentLabels(segments: segments) else {
            completion(.failure(ImageGenerationError.chargerImageError))
            return
        }
        completion(.success(image))
    }

    /// Draw actual map image from pixel array
    /// - Parameters:
    ///   - pixels: Pixel array containing rgba information for every pixel
    ///   - width: Width of map image from vacuum
    ///   - height: Height of map image from vacuum
    /// - Returns: Image with floor, walls, obstacles and segments
    private func drawMap(pixels: [MapData.Pixel]) -> UIImage? {
        let alphaInfo = CGImageAlphaInfo.premultipliedLast
        let bytesPerPixel = MemoryLayout<MapData.Pixel>.size
        let bytesPerRow = Int(imageSize.width) * bytesPerPixel
        let count = Int(imageSize.height) * bytesPerRow

        guard let providerRef = CGDataProvider(data: Data(bytes: pixels, count: count) as CFData) else { return nil }

        guard let cgImage = CGImage(
                    width: Int(imageSize.width),
                    height: Int(imageSize.height),
                    bitsPerComponent: 8,
                    bitsPerPixel: bytesPerPixel * 8,
                    bytesPerRow: bytesPerRow,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGBitmapInfo(rawValue: alphaInfo.rawValue),
                    provider: providerRef,
                    decode: nil,
                    shouldInterpolate: false,
                    intent: .defaultIntent) else { return nil }
                
        let size = CGSize(width: Int(imageSize.width) * scaleFactor, height: Int(imageSize.height) * scaleFactor)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = .none
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        return UIImage(cgImage: cgImage, scale: 0, orientation: .downMirrored)
    }

    /// Draw vacuum paths image
    /// - Parameters:
    ///   - path: Path object containing angle and point array
    ///   - image: Source image to draw on
    /// - Returns: Map image including paths
    private func drawMapPaths(path: MapData.Path, image: UIImage? = nil) -> UIImage? {
        UIGraphicsBeginImageContext(retinaImageSize)

        if let image = image {
            image.draw(at: .zero)
        }

        var color: UIColor
        let context = UIGraphicsGetCurrentContext()!
        context.setLineWidth(1.0)

        switch path.type {
        case .vacuum:
            color = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        case .predicted:
            color = UIColor(red: 1, green: 0, blue: 0, alpha: 0.8)
            context.setLineDash(phase: 0, lengths: [4, 2])
        case .goto:
            color = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        }

        context.setStrokeColor(color.cgColor)

        for index in 0..<path.points.count - 1 {
            if index != 0 {
                let point = path.points[index]
                let x = convertToMapCoordinate(point.x, offset: imagePosition.left)
                let y = convertToMapCoordinate(point.y, offset: imagePosition.top)

                let previousPoint = path.points[index - 1]
                let prevX = convertToMapCoordinate(previousPoint.x, offset: imagePosition.left)
                let prevY = convertToMapCoordinate(previousPoint.y, offset: imagePosition.top)

                context.move(to: CGPoint(x: prevX, y: prevY))
                context.addLine(to: CGPoint(x: x, y: y))
                context.strokePath()
            } else {
                let point = path.points[index]
                let x = convertToMapCoordinate(point.x, offset: imagePosition.left)
                let y = convertToMapCoordinate(point.y, offset: imagePosition.top)
                context.move(to: CGPoint(x: x, y: y))
            }
        }
        let tempImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return tempImage
    }

    /// Draw forbidden zones
    /// - Parameter zones: Forbidden zones objects
    /// - Returns: Image containing zones
    private func drawForbiddenZones(zones: MapData.ForbiddenZones) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: retinaImageSize)
        let tempImage = renderer.image { context in
            context.cgContext.setLineWidth(1.0)
            context.cgContext.setStrokeColor(UIColor(red: 1, green: 0, blue: 0, alpha: 0.8).cgColor)
            context.cgContext.setFillColor(UIColor(red: 1, green: 0, blue: 0, alpha: 0.5).cgColor)

            for zone in zones.zones {
                context.cgContext.move(to: CGPoint(x: convertToMapCoordinate(zone[0].x, offset: imagePosition.left), y: convertToMapCoordinate(zone[0].y, offset: imagePosition.top)))
                context.cgContext.addLine(to: CGPoint(x: convertToMapCoordinate(zone[1].x, offset: imagePosition.left), y: convertToMapCoordinate(zone[1].y, offset: imagePosition.top)))
                context.cgContext.addLine(to: CGPoint(x: convertToMapCoordinate(zone[2].x, offset: imagePosition.left), y: convertToMapCoordinate(zone[2].y, offset: imagePosition.top)))
                context.cgContext.addLine(to: CGPoint(x: convertToMapCoordinate(zone[3].x, offset: imagePosition.left), y: convertToMapCoordinate(zone[3].y, offset: imagePosition.top)))
                context.cgContext.addLine(to: CGPoint(x: convertToMapCoordinate(zone[0].x, offset: imagePosition.left), y: convertToMapCoordinate(zone[0].y, offset: imagePosition.top)))
                context.cgContext.fillPath()
                context.cgContext.strokePath()
            }
        }
        return tempImage
    }

    /// Draw vacuum robot image
    /// - Parameters:
    ///   - robot: Robot object containing angle and coordinates
    /// - Returns: Image containing robot
    private func drawRobot(robot: MapData.RobotPosition) -> UIImage? {
        let x = convertToMapCoordinate(robot.position.x, offset: imagePosition.left)
        let y = convertToMapCoordinate(robot.position.y, offset: imagePosition.top)

        guard let angle = robot.angle,
              let robotImage = UIImage(named: "robot")?
                .withHorizontallyFlippedOrientation()
                .rotate(angle: Float(angle + 90))
        else { return nil }

        let renderer = UIGraphicsImageRenderer(size: retinaImageSize)
        let tempImage = renderer.image { context in
            robotImage.draw(in: CGRect(origin: CGPoint(x: x - 12, y: y - 12), size: CGSize(width: 24, height: 24)))
        }

        return tempImage
    }

    /// Draw vacuum charger image
    /// - Parameters:
    ///   - charger: Charger coordinates
    /// - Returns: Image containing robot
    private func drawCharger(charger: MapData.Point) -> UIImage? {
        let x = convertToMapCoordinate(charger.x, offset: imagePosition.left)
        let y = convertToMapCoordinate(charger.y, offset: imagePosition.top)

        guard let chargerImage = UIImage(named: "charger") else { return nil }

        let renderer = UIGraphicsImageRenderer(size: retinaImageSize)
        let tempImage = renderer.image { context in
            chargerImage.draw(in: CGRect(origin: CGPoint(x: x - 4, y: y - 8), size: CGSize(width: 16, height: 16)))
        }

        return tempImage
    }

    /// Draw segment names image
    /// - Parameter segments: Segments object
    /// - Returns: Image containing labels
    private func drawSegmentLabels(segments: MapData.ImageData.Segments) -> UIImage? {
        let textColor = UIColor.white
        let backgroundColor = UIColor(white: 0, alpha: 0.6).cgColor
        let textFont = UIFont.systemFont(ofSize: 14)
        let textFontAttributes = [NSAttributedString.Key.font: textFont, NSAttributedString.Key.foregroundColor: textColor] as [NSAttributedString.Key : Any]

        let renderer = UIGraphicsImageRenderer(size: retinaImageSize)

        let tempImage = renderer.image{ context in
            for center in segments.center {
                guard let segmentType = SegmentType(rawValue: center.key) else { continue }
                // Get text and text width
                let text = segmentType.label
                let textWidth = text.width(withConstrainedHeight: 14, font: UIFont.systemFont(ofSize: 14))

                // Calculate coordinates and remove offsets for correct center
                let x = (center.value.position.x/center.value.count) * scaleFactor - imagePosition.left * scaleFactor - Int(textWidth/2)
                let y = Int(retinaImageSize.height) - (center.value.position.y/center.value.count) * 2 + imagePosition.top * 2 - 10

                let rect = CGRect(x: x - 4, y: y - 2, width: Int(textWidth) + 8, height: 20)
                let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: 4).cgPath

                context.cgContext.setFillColor(backgroundColor)
                context.cgContext.addPath(roundedRect)
                context.cgContext.fillPath()

                let textRect = CGRect(x: x, y: y, width: Int(retinaImageSize.width), height: Int(retinaImageSize.height))
                text.draw(with: textRect, options: .usesLineFragmentOrigin, attributes: textFontAttributes, context: nil)
            }
        }
        return tempImage
    }
}
