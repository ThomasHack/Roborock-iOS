//
//  RRFileParser.swift
//  Roborock
//
//  Created by Hack, Thomas on 28.06.21.
//

import Foundation
import UIKit

class MapFileParser {

    struct Chunk {
        var keyword: String
        var data: [UInt8]
    }

    enum Blocktype: Int {
        case charger = 1
        case image = 2
        case path = 3
        case gotoPath = 4
        case gotoPredictedPath = 5
        case currentlyCleanedZones = 6
        case gotoTarget = 7
        case robotPosition = 8
        case noGoAreas = 9
        case virtualWalls = 10
        case digest = 1024
    }

    fileprivate var majorVersion: Int?
    fileprivate var minorVersion: Int?
    fileprivate var mapIndex: Int?
    fileprivate var mapSequence: Int?

    fileprivate var image: Data?
    fileprivate var imageHeight: Int?
    fileprivate var imageWidth: Int?
    fileprivate var imageSize: Int?

    fileprivate var chargerX: Int?
    fileprivate var chargerY: Int?

    fileprivate var roboX: Int?
    fileprivate var roboY: Int?

    fileprivate var topOffset: Int?
    fileprivate var leftOffset: Int?

    fileprivate var setPointLength: Int?
    fileprivate var setPointSize: Int?
    fileprivate var setAngle: Int?

    fileprivate var roboPath: [CGPoint] = []

    public func drawMap() -> UIImage? {
        guard let image = image, let imageWidth = imageWidth, let imageHeight = imageHeight else { return nil }

        var imageData: [UInt8] = []
        var color: UIColor
        for pixel in image {
            switch pixel {
            case 0:
                color = UIColor(red: 161, green: 219, blue: 255, alpha: 1) // occupied color
                break
            case 1:
                color = UIColor(red: 31, green: 151, blue: 255, alpha: 1) // free color
                break
            default:
                print(pixel)
                color = UIColor(red: 86, green: 175, blue: 252, alpha: 1) // segment color
                break
            }

            guard let colorComponents = color.getRGBAComponents() else { return nil }

            imageData.append(UInt8(colorComponents.red))
            imageData.append(UInt8(colorComponents.green))
            imageData.append(UInt8(colorComponents.blue))
            imageData.append(UInt8(255))
        }

        guard let cgImage = imagefromPixelValues(imageData, width: imageWidth, height: imageHeight) else { return nil }
        let uiImage = UIImage(cgImage: cgImage)
        return uiImage
    }

    public func imagefromPixelValues(_ pixelValues: [UInt8]?, width: Int, height: Int) -> CGImage? {
        var imageRef: CGImage?
        if var pixelValues = pixelValues {
            let bitsPerComponent = 8
            let bytesPerPixel = 1
            let bitsPerPixel = bytesPerPixel * bitsPerComponent
            let bytesPerRow = bytesPerPixel * width
            let totalBytes = height * bytesPerRow

            imageRef = withUnsafePointer(to: &pixelValues, {
                ptr -> CGImage? in
                var imageRef: CGImage?
                let colorSpaceRef = CGColorSpaceCreateDeviceGray()
                let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).union(CGBitmapInfo())
                let data = UnsafeRawPointer(ptr.pointee).assumingMemoryBound(to: UInt8.self)
                let releaseData: CGDataProviderReleaseDataCallback = {
                    (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
                }

                if let providerRef = CGDataProvider(dataInfo: nil, data: data, size: totalBytes, releaseData: releaseData) {
                    imageRef = CGImage(width: width,
                                       height: height,
                                       bitsPerComponent: bitsPerComponent,
                                       bitsPerPixel: bitsPerPixel,
                                       bytesPerRow: bytesPerRow,
                                       space: colorSpaceRef,
                                       bitmapInfo: bitmapInfo,
                                       provider: providerRef,
                                       decode: nil,
                                       shouldInterpolate: false,
                                       intent: CGColorRenderingIntent.defaultIntent)
                }

                return imageRef
            })
        }

        return imageRef
    }

    public func parseMapData(_ data: Data) {

        self.majorVersion = data.getInt16(position: "0x08".hexaToDecimal)
        self.minorVersion = data.getInt16(position: "0x0A".hexaToDecimal)
        self.mapIndex = data.getInt32(position: "0x0C".hexaToDecimal)
        self.mapSequence = data.getInt32(position: "0x10".hexaToDecimal)

        var nextPos = data.getInt16(position: "0x02".hexaToDecimal)

        print("nextPos: \(nextPos) count: \(data.count)")

        while nextPos < data.count {
            guard let header = data.getBytes(position: nextPos, length: "0x20".hexaToDecimal) else { return }
            // let header = data.getBytes(position: nextPos, length: "0x20".hexaToDecimal)

            let headerLength = header.getInt16(position: "0x02".hexaToDecimal)
            let dataLength = header.getInt32(position: "0x04".hexaToDecimal)

            guard let blockTypeHeader = header.getBytes(position: 0, length: 2) else { print("no block header"); return }
            let blockType = Blocktype(rawValue: blockTypeHeader.getInt16(position: 0))

            print("position: \(nextPos)header: \(headerLength), block: \(dataLength)")

            switch blockType {
            case .charger:
                print(".charger")
                self.chargerX = header.getInt32(position: "0x08".hexaToDecimal)
                self.chargerY = header.getInt32(position: "0x0C".hexaToDecimal)
                break
            case .image:
                print(".image")
                let imageSize = header.getInt32(position: "0x04".hexaToDecimal)
                self.imageSize = imageSize
                self.imageWidth = header.getInt32(position: "0x14".hexaToDecimal)
                self.imageHeight = header.getInt32(position: "0x10".hexaToDecimal)
                self.topOffset = header.getInt32(position: "0x08".hexaToDecimal)
                self.leftOffset = header.getInt32(position: "0x0C".hexaToDecimal)
                self.image = data.getBytes(position: (nextPos + "0x18".hexaToDecimal), length: imageSize)
                break
            case .path:
                print(".path")
                let pairs = header.getInt32(position: "0x04".hexaToDecimal)
                self.setPointLength = header.getInt32(position: "0x08".hexaToDecimal)
                self.setPointSize = header.getInt32(position: "0x0C".hexaToDecimal)
                self.setAngle = header.getInt32(position: "0x10".hexaToDecimal)
                let startPosition = "0x14".hexaToDecimal + nextPos
                for index in 0..<pairs {
                    guard
                        let leftOffset = self.leftOffset,
                        let topOffset = self.topOffset,
                        let xBytes = data.getBytes(position: (startPosition + index * 4), length: 2),
                        let yBytes = data.getBytes(position: startPosition + index * 4 + 2, length: 2) else { return }

                    let x = 1024 - xBytes.getInt16(position: 0) / 50 - leftOffset
                    let y = yBytes.getInt16(position: 0) / 50 - topOffset
                    roboPath.append(CGPoint(x: x, y: y))
                }
                break
            case .gotoPath:
                print(".gotopath")
                break
            case .gotoPredictedPath:
                print(".gotoPredictedPath")
                break
            case .currentlyCleanedZones:
                print(".currentlyCleanedZones")
                break
            case .gotoTarget:
                print(".gotoTarget")
                break
            case .robotPosition:
                print(".robotPosition")
                self.roboX = header.getInt32(position: "0x08".hexaToDecimal)
                self.roboY = header.getInt32(position: "0x0C".hexaToDecimal)
                break
            case .noGoAreas:
                print(".noGoAreas")
                break
            case .virtualWalls:
                print(".virtualWalls")
                break
            case .digest:
                print(".digest")
                break
            default:
                print("Error: Unknown blocktype")
                break
            }
            nextPos += headerLength + dataLength
        }
    }

    public func getImage() -> Data? {
        return image
    }

    public func setImage(image: Data) {
        self.image = image
    }

    public func getImageSize() -> Int? {
        return imageSize
    }

    public func getImageHeight() -> Int? {
        return imageHeight
    }

    public func getImageWidth() -> Int? {
        return imageWidth
    }

    public func getTop() -> Int? {
        return topOffset
    }

    public func getLeft() -> Int? {
        return self.leftOffset
    }
}
