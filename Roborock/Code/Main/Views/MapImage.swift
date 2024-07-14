//
//  MapImage.swift
//  Roborock
//
//  Created by Hack, Thomas on 24.02.24.
//

import UIKit

public enum MapImage: Equatable {
    case activeZone(UIImage)
    case charger(UIImage)
    case goToTarget(UIImage)
    case map(UIImage)
    case path(UIImage)
    case predictedPath(UIImage)
    case noGoArea(UIImage)
    case noMopArea(UIImage)
    case robot(UIImage)
    case virtualWall(UIImage)

    var associatedValue: UIImage {
        switch self {
        case .activeZone(let image),
                .charger(let image),
                .goToTarget(let image),
                .map(let image),
                .path(let image),
                .predictedPath(let image),
                .virtualWall(let image),
                .noGoArea(let image),
                .noMopArea(let image),
                .robot(let image):
            return image
        }
    }
}

public struct MapImages: Equatable {
    var images: [MapImage]

    var map: UIImage? {
        images.first(where: {
            if case .map = $0 { return true }
            return false
        })?.associatedValue
    }

    var paths: [UIImage] {
        images
            .filter({
                switch $0 {
                case .path, .predictedPath:
                    return true
                default:
                    return false
                }
            })
            .map { $0.associatedValue }
    }

    var virtualWalls: [UIImage] {
        images
            .filter({
                if case .virtualWall = $0 { return true }
                return false
            })
            .map { $0.associatedValue }
    }

    var zones: [UIImage] {
        images
            .filter({
                switch $0 {
                case .activeZone, .noGoArea, .noMopArea:
                    return true
                default:
                    return false
                }
            })
            .map { $0.associatedValue }
    }

    var targets: [UIImage] {
        images
            .filter({
                if case .goToTarget = $0 { return true }
                return false
            })
            .map { $0.associatedValue }
    }

    var charger: UIImage? {
        images
            .first(where: {
                if case .charger = $0 { return true }
                return false
            })?.associatedValue
    }

    var robot: UIImage? {
        images
            .first(where: {
                if case .robot = $0 { return true }
                return false
            })?.associatedValue
    }
}
