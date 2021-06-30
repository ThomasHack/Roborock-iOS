//
//  RRFileParser.swift
//  Roborock
//
//  Created by Hack, Thomas on 28.06.21.
//

import Foundation
import UIKit

struct PixelData {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8 = 255
}

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
    fileprivate var mapImageData: MapData.Image?


    fileprivate var setPointLength: Int?
    fileprivate var setPointSize: Int?
    fileprivate var setAngle: Int?

    fileprivate var roboPath: [CGPoint] = []

    public func parse(_ data: Data) {

        guard data.getUtf8(position: 0) == "r" && data.getUtf8(position: 1) == "r" else {
            return
        }

        let mapData = parseBlock(data, offset: "0x14".hexaToDecimal)
        guard let mapImage = mapData.image else { return }
        print("pixel count: \(mapImage.pixels.count)") // 13405
        // let pixels = generatePixelData(mapData)
        // let image = drawMapImage(pixels: pixels, width: mapData.dimensions.width, height: mapData.dimensions.height)
        // print("\(image)")
    }
    
    fileprivate func generatePixelData(_ image: MapData.Image) -> [PixelData] {
        let freeColor = UIColor.green.toRgba
        let occupiedColor = UIColor.red.toRgba
        let segmentBorderColor = UIColor.darkGray.toRgba
        var segmentColor = UIColor.gray.toRgba
        
        var imageData: [PixelData] = []
        
        if !image.pixels.isEmpty {
            var color: (r: UInt8, g: UInt8, b: UInt8, a: UInt8)
            if image.segments.count < 2 {
                segmentColor = freeColor
            }
            for (key, value) in image.pixels {
                switch value {
                case 1:
                    color = freeColor
                case 0:
                    color = occupiedColor
                default:
                    // if (image.segments.borders.contains(key)) {
                    //     color = segmentBorderColor
                    //     break
                    // }
                    color = segmentColor
                }
                imageData.append(PixelData(r: color.r, g: color.g, b: color.b, a: color.a))
            }
            return imageData
        }
        return []
    }
    
    fileprivate func drawMapImage(pixels: [PixelData], width: Int, height: Int) -> UIImage? {
        guard width > 0 && height > 0 else { return nil }
            // guard pixels.count == width * height else { return nil }

            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
            let bitsPerComponent = 8
            let bitsPerPixel = 32

            var data = pixels // Copy to mutable []
            guard let providerRef = CGDataProvider(data: NSData(bytes: &data,
                                    length: data.count * MemoryLayout<PixelData>.size)
                )
                else { return nil }

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
                )
                else { return nil }

            return UIImage(cgImage: cgim)
    }

    fileprivate func parseBlock(_ block: Data, offset: Int, mapData: MapData = MapData()) -> MapData {
        if block.count <= offset {
            return mapData
        }

        guard let blockTypeHeader = block.getBytes(position: "0x00".hexaToDecimal + offset, length: 2) else {
            print("no block header");
            return mapData
        }
        let headerLength = block.getInt16(position: "0x02".hexaToDecimal + offset)
        let blockLength = block.getInt32(position: "0x04".hexaToDecimal + offset)
        let blockType = Blocktype(rawValue: block.getInt16(position: "0x00".hexaToDecimal + offset))

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

    fileprivate func parseRobotPositionBlock(_ block: Data, blockLength: Int, offset: Int) -> MapData.RobotPosition {
        let x = block.getInt32(position: "0x08".hexaToDecimal + offset)
        let y = block.getInt32(position: "0x0C".hexaToDecimal + offset)
        let angle = blockLength >= 12 ? block.getInt32(position: "0x10".hexaToDecimal + offset) : nil
        return MapData.RobotPosition(x: x, y: y, angle: angle)
    }

    fileprivate func parseChargerLocationBlock(_ block: Data, offset: Int) -> MapData.ChargerLocation {
        let x = block.getInt32(position: "0x08".hexaToDecimal + offset)
        let y = block.getInt32(position: "0x0C".hexaToDecimal + offset)
        return MapData.ChargerLocation(x: x, y: y)
    }

    fileprivate func parseImageBlock(_ block: Data, headerLength: Int, blockLength: Int, offset: Int) -> MapData.Image {
        let segments = MapData.Image.Segments(count: block.getInt32(position: "0x08".hexaToDecimal + offset),
                                                 center: [:],
                                                 borders: [],
                                                 neighbours: [:])

        let position = MapData.Image.Position(top: block.getInt32(position: "0x08".hexaToDecimal + offset),
                                                 left: block.getInt32(position: "0x0C".hexaToDecimal + offset))

        let dimensions = MapData.Image.Dimensions(height: block.getInt32(position: "0x10".hexaToDecimal + offset),
                                                     width: block.getInt32(position: "0x14".hexaToDecimal + offset))

        let box = MapData.Image.Box(minX: .max, minY: .max, maxX: .max, maxY: .max)

        var image = MapData.Image(segments: segments, position: position, dimensions: dimensions, box: box, pixels: [:])

        if dimensions.width > 0 && dimensions.height > 0 {
            image = parseImagePixelBlock(block, blockLength: blockLength, image: image, offset: offset)
        } else {
            image.box = MapData.Image.Box(minX: 0, minY: 0, maxX: 100, maxY: 100)
        }
        return image
    }

    fileprivate func parseImagePixelBlock(_ block: Data, blockLength: Int, image: MapData.Image, offset: Int) -> MapData.Image {
        var x: Int
        var y: Int
        var v: Int
        var s: Int
        var k: Int
        var m: Bool
        var n: Bool

        var tempImage = image

        tempImage.position.top = MapFileParser.dimensionPixels - tempImage.position.top - tempImage.dimensions.height

        for index in 0..<blockLength {
            x = (index/MapFileParser.dimensionPixels) + 0
            y = (MapFileParser.dimensionPixels - (index/MapFileParser.dimensionPixels)) + 0
            k = y * MapFileParser.dimensionPixels + x
            
            print("\(k)")

            let blockType = block.getInt8(position: "0x00".hexaToDecimal + offset + index)

            switch blockType {
            case 0:
                v = -1 // empty
                break
            case 1:
                v = 0 // obstacle
                break
            default:
                v = 1 // floor
                s = (blockType & 248) >> 31
                if s != 0 {
                    v = (s << 1) //segment
                    // centers
                    if tempImage.segments.center[s] == nil {
                        tempImage.segments.center[s] = MapData.Image.Center(x: 0, y: 0, count: 0)
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
            if v < 0 {
                continue
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

    private func parseGoToPredictedPathBlock(_ block: Data, blockLength: Int, offset: Int) -> MapData.Path {
        var points: [Int] = []
        let currentAngle = block.getInt32(position: "0x10".hexaToDecimal + offset)

        for index in 0..<blockLength {
            points.append(block.getInt16(position: "0x14".hexaToDecimal) + offset + index)
            points.append(block.getInt16(position: "0x14".hexaToDecimal) + offset + index + 2)
        }
        return MapData.Path(currentAngle: currentAngle, points: points)
    }
}
