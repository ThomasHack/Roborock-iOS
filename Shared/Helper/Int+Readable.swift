//
//  Int+Readable.swift
//  Roborock
//
//  Created by Hack, Thomas on 29.02.24.
//

import Foundation

extension Int {
    var readableArea: String {
        String(format: "%.2f", Double(self) / 10000)
    }

    var readableTime: String {
        let minutes = String(format: "%02d", (self % 3600) / 60)
        let seconds = String(format: "%02d", (self % 3600) % 60)
        return "\(minutes):\(seconds)"
    }
}
