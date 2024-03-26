//
//  File.swift
//  
//
//  Created by Hack, Thomas on 24.02.24.
//

import UIKit

extension UIColor {
    public static var freeColor: UIColor {
        guard let color = UIColor(named: "freeColor") else { fatalError("Color 'freeColor' missing.") }
        return color
    }

    public static var floorColor: UIColor {
        guard let color = UIColor(named: "floorColor") else { fatalError("Color 'floorColor' missing.") }
        return color
    }

    public static var obstacleColor: UIColor {
        guard let color = UIColor(named: "obstacleColor") else { fatalError("Color 'obstacleColor' missing.") }
        return color
    }

    public static var dividerColor: UIColor {
        guard let color = UIColor(named: "dividerColor") else { fatalError("Color 'dividerColor' missing.") }
        return color
    }

    public static var selectedColor: UIColor {
        guard let color = UIColor(named: "selectedColor") else { fatalError("Color 'selectedColor' missing.") }
        return color
    }

    public static var labelTextColor: UIColor {
        guard let color = UIColor(named: "labelTextColor") else { fatalError("Color 'labelTextColor' missing.") }
        return color
    }

    public static var forbiddenZoneStroke: UIColor {
        guard let color = UIColor(named: "noGoZoneStroke") else { fatalError("Color 'noGoZoneStroke' missing.") }
        return color
    }

    public static var forbiddenZoneBackground: UIColor {
        guard let color = UIColor(named: "noGoZoneBackground") else { fatalError("Color 'noGoZoneBackground' missing.") }
        return color
    }

    public static var attachedColor: UIColor {
        guard let color = UIColor(named: "attachedColor") else { fatalError("Color 'attachedColor' missing.") }
        return color
    }

    public static var notAttachedColor: UIColor {
        guard let color = UIColor(named: "notAttachedColor") else { fatalError("Color 'notAttachedColor' missing.") }
        return color
    }
}
