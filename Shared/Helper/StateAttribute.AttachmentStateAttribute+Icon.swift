//
//  Attachment+Icon.swift
//  Roborock
//
//  Created by Hack, Thomas on 01.03.24.
//

import Foundation
import RoborockApi

extension StateAttribute.AttachmentStateAttribute {
    var icon: String {
        switch self.type {
        case .dustbin:
            return "xmark.bin.fill"
        case .mop:
            return "windshield.rear.and.wiper"
        case .watertank:
            return "drop.fill"
        }
    }
}
