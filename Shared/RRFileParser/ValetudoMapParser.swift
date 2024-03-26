//
//  ValetudoMapParser.swift
//  Roborock
//
//  Created by Hack, Thomas on 22.02.24.
//

import ComposableArchitecture
import RoborockApi
import UIKit

public class ValetudoMapParser {
    static let live = ValetudoMapParser()

    private var map: Map?
    private var dimensions: Map.Dimensions?
    private var canvasSize: CGSize?
    private var pixelSize: CGFloat?
    private var offset: CGSize?

    public enum MapParserError: Error, Equatable {
        case mapDimensionsMissing
        case mapDataMissing
    }

    public func parseMap(_ map: Map, selectedSegments: [String]) throws -> MapImage? {
        self.setup(map: map)
        return try self.drawMap(selectedSegments: selectedSegments)
    }

    public func parseEntities(_ map: Map) throws -> [MapImage] {
        self.setup(map: map)
        return self.parseEntities(map.entities)
    }

    public func drawMap(selectedSegments: [String]) throws -> MapImage? {
        guard let map = self.map else { throw MapParserError.mapDataMissing }
        return self.parseLayers(layers: map.layers, selectedSegments: selectedSegments)
    }

    private func setup(map: Map) {
        self.map = map
        self.dimensions = map.calculatedDimensions
        self.canvasSize = map.calculatedDimensions.sum
        self.pixelSize = CGFloat(integerLiteral: map.pixelSize)
        self.offset = CGSize(width: map.calculatedDimensions.min.x * 5, height: map.calculatedDimensions.min.y * 5)
    }

    private func parseLayers(layers: [Map.Layer], selectedSegments: [String]) -> MapImage? {
        guard let canvasSize = self.canvasSize else { return nil }
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let segments = layers.filter({ $0.type == .segment })

        let image = renderer.image { context in
            for layer in segments {
                self.parseLayer(context: context, layer: layer, selectedSegments: selectedSegments)
            }
            if let walls = layers.first(where: { $0.type == .wall }) {
                self.parseLayer(context: context, layer: walls, selectedSegments: selectedSegments)
            }
            if let floor = layers.first(where: { $0.type == .floor }) {
                self.parseLayer(context: context, layer: floor, selectedSegments: selectedSegments)
            }
        }
        return .map(image)
    }

    private func parseLayer(context: UIGraphicsImageRendererContext, layer: Map.Layer, selectedSegments: [String]) {
        var color = layer.type.color
        if let segmentId = layer.metaData.segmentId, selectedSegments.contains(segmentId) {
            color = .selectedColor
        }
        self.drawLayer(context: context, pixels: layer.pixels, color: color)
    }

    private func drawLayer(context: UIGraphicsImageRendererContext, pixels: [CGPoint], color: UIColor) {
        guard let dimensions = self.dimensions  else { return }
        color.setFill()
        for pixel in pixels {
            let rect = CGRect(x: pixel.x - dimensions.min.x, y: pixel.y - dimensions.min.y, width: 1, height: 1)
            context.fill(rect)
        }
    }

    private func parseEntities(_ entities: [Map.Entity]) -> [MapImage] {
        var images: [MapImage] = []
        for entity in entities {
            guard let image = parseEntity(entity) else { continue }
            images.append(image)
        }
        return images
    }

    private func parseEntity(_ entity: Map.Entity) -> MapImage? {
        let paths = entity.points
        switch entity.type {
        case .activeZone:
            // TODO: change method
            return activeZone(paths: paths)
        case .chargerLocation:
            return charger(paths: paths)
        case .goToTarget:
            return goToTarget(paths: paths)
        case .noGoArea:
            return noGoArea(paths: paths)
        case .noMopArea:
            return noMopArea(paths: paths)
        case .path:
            return path(paths: paths, color: entity.type.color)
        case .predictedPath:
            return predictedPath(paths: paths, color: entity.type.color)
        case .robotPosition:
            return robot(paths: paths, angle: entity.metaData.angle)
        case .virtualWall:
            return virtualWall(paths: paths)
        }
    }

    private func activeZone(paths: [CGPoint]) -> MapImage? {
        guard let image = self.drawZone(paths: paths, fillColor: .activeZoneBackground, strokeColor: .activeZoneStroke) else { return nil }
        return .activeZone(image)
    }

    private func charger(paths: [CGPoint]) -> MapImage? {
        guard let position = paths.first, let image = self.drawCharger(point: position) else { return nil }
        return .charger(image)
    }

    private func goToTarget(paths: [CGPoint]) -> MapImage? {
        guard let position = paths.first, let image = self.drawPoint(point: position, image: nil) else { return nil }
        return .goToTarget(image)
    }

    private func noGoArea(paths: [CGPoint]) -> MapImage? {
        guard let image = self.drawZone(paths: paths, fillColor: .noGoZoneBackground, strokeColor: .noGoZoneStroke) else { return nil }
        return .noGoArea(image)
    }

    private func noMopArea(paths: [CGPoint]) -> MapImage? {
        guard let image = self.drawZone(paths: paths, fillColor: .noMopZoneBackground, strokeColor: .noMopZoneStroke) else { return nil }
        return .noMopArea(image)
    }

    private func path(paths: [CGPoint], color: UIColor) -> MapImage? {
        guard let image = self.drawPath(paths: paths, predicted: false, color: color) else { return nil }
        return .path(image)
    }

    private func predictedPath(paths: [CGPoint], color: UIColor) -> MapImage? {
        guard let image = self.drawPath(paths: paths, predicted: true, color: color) else { return nil }
        return .predictedPath(image)
    }

    private func robot(paths: [CGPoint], angle: Int?) -> MapImage? {
        guard let position = paths.first, let angle = angle, let image = self.drawRobot(point: position, angle: angle) else { return nil }
        return .robot(image)
    }

    private func virtualWall(paths: [CGPoint]) -> MapImage? {
        guard let image = self.drawZone(paths: paths, fillColor: .forbiddenZoneBackground, strokeColor: .forbiddenZoneStroke) else { return nil }
        return .virtualWall(image)
    }

    private func drawPath(paths: [CGPoint], predicted: Bool, color: UIColor) -> UIImage? {
        guard let canvasSize = self.canvasSize, let pixelSize = self.pixelSize, let offset = self.offset else { return nil }

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasSize.width * pixelSize, height: canvasSize.height * pixelSize))
        let tempImage = renderer.image { context in
            context.cgContext.setStrokeColor(color.cgColor)
            if predicted {
                context.cgContext.setLineDash(phase: 0, lengths: [4, 2])
            }
            for (index, path) in paths.enumerated() {
                if index == 0 {
                    context.cgContext.move(to: CGPoint(x: path.x - offset.width, y: path.y - offset.height))

                } else {
                    context.cgContext.addLine(to: CGPoint(x: path.x - offset.width, y: path.y - offset.height))
                    context.cgContext.strokePath()
                    context.cgContext.move(to: CGPoint(x: path.x - offset.width, y: path.y - offset.height))
                }
            }
        }
        return tempImage
    }

    private func drawRobot(point: CGPoint, angle: Int) -> UIImage? {
        guard let canvasSize = self.canvasSize, let pixelSize = self.pixelSize, let offset = self.offset else { return nil }
        let robotSize = CGSize(width: 48, height: 48)

        guard let robotImage = #imageLiteral(resourceName: "robot")
                .withHorizontallyFlippedOrientation()
                .rotate(angle: Float(angle)) else { return nil }

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasSize.width * pixelSize, height: canvasSize.height * pixelSize))
        let tempImage = renderer.image { _ in
            robotImage.draw(in: CGRect(origin: CGPoint(
                x: point.x - offset.width - robotSize.width / 2,
                y: point.y - offset.height - robotSize.height / 2), size: robotSize
            ))
        }
        return tempImage
    }

    private func drawCharger(point: CGPoint) -> UIImage? {
        guard let canvasSize = self.canvasSize, let pixelSize = self.pixelSize, let offset = self.offset else { return nil }
        let chargerSize = CGSize(width: 32, height: 32)
        let chargerImage = #imageLiteral(resourceName: "charger")
            .withHorizontallyFlippedOrientation()
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasSize.width * pixelSize, height: canvasSize.height * pixelSize))
        let tempImage = renderer.image { _ in
            chargerImage.draw(in: CGRect(
                origin: CGPoint(
                    x: point.x - offset.width - chargerSize.width / 2,
                    y: point.y - offset.height - chargerSize.height / 2
                ),
                size: chargerSize
            ))
        }
        return tempImage
    }

    private func drawZone(paths: [CGPoint], fillColor: UIColor, strokeColor: UIColor) -> UIImage? {
        guard let canvasSize = self.canvasSize, let pixelSize = self.pixelSize, let offset = self.offset else { return nil }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasSize.width * pixelSize, height: canvasSize.height * pixelSize))
        let tempImage = renderer.image { context in
            context.cgContext.setLineWidth(2.0)
            context.cgContext.setStrokeColor(strokeColor.cgColor)
            context.cgContext.setFillColor(fillColor.cgColor)

            for (index, point) in paths.enumerated() {
                if index == 0 {
                    context.cgContext.move(to: CGPoint(x: point.x - offset.width, y: point.y - offset.height))
                } else {
                    context.cgContext.addLine(to: CGPoint(x: point.x - offset.width, y: point.y - offset.height))
                }
            }
            context.cgContext.drawPath(using: .fillStroke)
        }
        return tempImage
    }

    private func drawPoint(point: CGPoint, image: UIImage?) -> UIImage? {
        guard let canvasSize = self.canvasSize, let pixelSize = self.pixelSize, let offset = self.offset else { return nil }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasSize.width * pixelSize, height: canvasSize.height * pixelSize))
        let tempImage = renderer.image { context in
            if let image = image {
                let size = CGSize(width: 24 * pixelSize, height: 24 * pixelSize)
                image.draw(in: CGRect(
                    origin: CGPoint(
                        x: point.x - offset.width - size.width / 2,
                        y: point.y - offset.height - size.height / 2
                    ),
                    size: size
                ))
            } else {
                let size = CGSize(width: 8 * pixelSize, height: 8 * pixelSize)
                context.cgContext.setStrokeColor(UIColor.red.cgColor)
                context.cgContext.setFillColor(UIColor.red.cgColor)
                context.cgContext.addEllipse(in: CGRect(
                    origin: CGPoint(
                        x: point.x - offset.width - size.width / 2,
                        y: point.y - offset.height - size.height / 2
                    ),
                    size: size
                ))
                context.cgContext.drawPath(using: .fillStroke)
            }
        }
        return tempImage
    }
}
